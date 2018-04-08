# Builds rule objects from data in YAML files.

require 'yaml'
require 'lib/constraint'
require 'lib/build_option'
require 'lib/effect'
require 'lib/constraint'

class Parser

  # Indicates an invalid input file of some kind.
  class Error < StandardError
  end

  # Represents a lookup table, used in the input to avoid repetition.
  # :name is any string (used for human-readability only),
  # :parameters is a list of "variable" resource names (conventionally prefixed with $)
  #                that must be defined when the table is used.
  # :rows is a list of effects (BuildOption::Choices) using those variables.
  Table = Struct.new(:name, :parameters, :rows)

  # @param source [IO] The data file, etc. to read.
  def initialize(source)
    @source = source
  end

  # @return [Array<Constraint>]
  def constraints
    @constraints ||= (explicit_constraints + implied_constraints)
  end

  # The tables defined by the input data file, keyed by ID.
  # @return [Hash<String, Table>]
  def tables
    @tables ||= {}.tap do |tables|
      parsed_data['tables'].map do |table|
        parsed_table_rows = parse_choices(table['rows'])
        tables[table['id']] = Table.new(table['name'], table['parameters'], parsed_table_rows)
      end
    end
  end

  # @return [Array<BuildOption>]
  def build_options
    @build_options ||= parsed_data['build_options'].map do |option|

      choice_data = parse_choices(option['choices'])

      # If we're using a shared table, add choices from it
      table_call = option['choices_from_table']
      if table_call
        choice_data += choices_from_table(table_call, tables)
      end

      # Explicitly set choices to nil if the option doesn't require further decisions.
      choice_data = nil if choice_data.empty?

      BuildOption.new(option['name'],
                      parse_effects(option),
                      choice_data)
    end
  end

  private

  def parsed_data
    @parsed_data ||= YAML.load(@source.readlines.join("\n"))
  end

  # @return [Array<Constraint>] Constraints explicitly stated in the input file.
  def explicit_constraints
    (parsed_data['resources'] || []).map do |resource|
      Constraint.new(resource['name'], maximum: resource['maximum'])
    end
  end

  # @return [Array<Constraint>] Constraints implied by option properties
  #                             (e.g. things that can't be taken multiple times).
  def implied_constraints

    # TODO: processing build options twice unnecessarily.
    (parsed_data['build_options'] || []).map do |option|
      build_option_constraints(option)
    end.flatten
  end

  # @param [Hash] build_option_data
  # @return [Array<Constraint>] Constraints implied by a particular build option
  #                             (may be empty if no constraints).
  def build_option_constraints(build_option)

    # Only care about no-multiples-of-this constraint for now.
    if build_option['once-only']
      option_count_resource = unique_resource_name(build_option['name'],
                                                   'count')
      [
        Constraint.new(option_count_resource, maximum: 1)
      ]
    else
      []
    end
  end

  # Generate a canonicalized name for the given resource implied by a build
  # option.
  # @param build_option_name [String]
  # @param suffix [String] A suffix indicating the meaning of this resource.
  # @return [String] A resource name not previously used by this parser,
  #                  with the given prefix and suffix.
  def unique_resource_name(build_option_name, suffix)
    normalised_name = build_option_name.downcase.gsub(/[^a-z]+/, '-')
    "#{normalised_name}##{suffix}"
  end

  # Parse all effects of a build option -- both explicit ones and those
  # implied by other flags.
  # @param build_option [Hash]
  # @return [Array<Effect>, NilClass]
  def parse_effects(build_option)
    explict_effects(build_option['effects']) + implied_effects(build_option)
  end

  # @param effects_data [Array<Hash>, NilClass]
  # @return [Array<Effect>] Empty if input was nil.
  def explict_effects(effects_data)
    if effects_data.nil?
      []
    else
      effects_data.map { |effect| parse_effect(effect) }
    end
  end

  # @param effect_data [Hash{String,Object}] Raw effect data
  # @return Effect
  def parse_effect(effect_data)

    # TODO: why are these different things?
    resource_or_stat = effect_data['resource'] || effect_data['statistic']

    if effect_data['value']
      Effect::SetValue.new(resource_or_stat, effect_data['value'])
    elsif effect_data['change']
      Effect::Change.new(resource_or_stat, effect_data['change'])
    else
      # TODO: should use our Error class.
      raise "Unrecognised effect type #{effect_data.inpsect}"
    end
  end

  # Create effects used to implement build option flags (e.g. no multiples)
  #
  # @param build_option [Hash]
  # @return [Array<Effect>]
  def implied_effects(build_option)

    # Only care about no-multiples-of-this constraint for now.
    # TODO duplication.
    if build_option['once-only']
      option_count_resource = unique_resource_name(build_option['name'],
                                                   'count')
      [
        Effect::Change.new(option_count_resource, +1)
      ]
    else
      []
    end
  end

  # Generate concrete choices from a reference to an abstracted table.
  #
  # @param table_call [Array<Hash>, NilClass]
  #                   The data in the choices-from-table element.
  # @param known_tables [Hash{String,Table}] Tables available to fill choices from.
  # @return [Array<BuildOption::Choice>, NilClass]
  def choices_from_table(table_call, known_tables)
    table_id = table_call['table']
    table = known_tables[table_id]

    # Validate that the table is being invoked correctly.
    raise Error, "Reference to undefined table #{table_id}" unless table

    renamings = table_call.select { |key, _value| key.start_with?('$') }
    unless renamings.keys == table.parameters
      raise Error, "Reference to table #{table.name} (#{table_id}) with non-matching parameters: "\
                    "expected #{table.parameters.inspect} but saw #{arguments.inspect}"
    end

    table.rows.map do |row|
      choice_from_table_row(row, renamings)
    end
  end

  # @param row_data [Hash{String,Object}]
  # @param renamings [Hash{String,String}] Attributes to be renamed within the table.
  def choice_from_table_row(row_data, renamings)

      # Rename bound (parameter) stats to
      # the stats we're actually using in this case.
      effects_after_renaming = row_data.effects.map do |effect|
        if renamings[effect.resource]
          effect.rename(renamings[effect.resource])
        else
          effect
        end
      end

      BuildOption::Choice.new(row_data['name_suffix'], effects_after_renaming)
  end

  # @param choice_data [Array<Hash>, NilClass]
  # @return [Array<BuildOption::Choice>]
  def parse_choices(choice_data)
    if choice_data.nil?
      return []
    end

    choice_data.map do |choice|
      choice_effects = parse_effects(choice) || []
      BuildOption::Choice.new(choice['name_suffix'], choice_effects)
    end
  end
end
