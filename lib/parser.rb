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
    @constraints ||= parsed_data['resources'].map do |resource|
      Constraint.new(resource['name'], maximum: resource['maximum'])
    end
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

      BuildOption.new(option['name'],
                      parse_effects(option['effects']),
                      choice_data)
    end
  end

  private

  def parsed_data
    @parsed_data ||= YAML.load(@source.readlines.join("\n"))
  end

  # @param effect_data [Array<Hash>, NilClass]
  # @return [Array<Effect>, NilClass]
  def parse_effects(effect_data)
    if effect_data.nil?
      return nil
    end

    effect_data.map do |effect|

      # TODO: why are these different things?
      resource_or_stat = effect['resource'] || effect['statistic']
      if effect['value']
        Effect::SetValue.new(resource_or_stat, effect['value'])
      elsif effect['change']
        Effect::Change.new(resource_or_stat, effect['change'])
      else
        raise "Unrecognised effect type #{effect.inpsect}"
      end
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

    arguments = table_call.keys - %w[ table ]
    unless arguments == table.parameters
      raise Error, "Reference to table #{table.name} (#{table_id}) with non-matching parameters: "\
                    "expected #{table.parameters.inspect} but saw #{arguments.inspect}"
    end

    table.rows.map do |row|

      # Rename bound (parameter) stats to
      # the stats we're actually using in this case.
      effects_after_renaming = row.effects.map do |effect|
        if arguments.include?(effect.resource)
          renamed_resource = table_call[effect.resource]

          effect.rename(renamed_resource)
        else
          effect
        end
      end

      BuildOption::Choice.new(row['name_suffix'], effects_after_renaming)
    end
  end

  # @param choice_data [Array<Hash>, NilClass]
  # @return [Array<BuildOption::Choice>]
  def parse_choices(choice_data)
    if choice_data.nil?
      return []
    end

    choice_data.map do |choice|
      choice_effects = parse_effects(choice['effects']) || []
      BuildOption::Choice.new(choice['name_suffix'], choice_effects)
    end
  end
end
