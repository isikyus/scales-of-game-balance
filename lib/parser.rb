# Builds rule objects from data in YAML files.

require 'yaml'
require 'lib/constraint'
require 'lib/build_option'
require 'lib/effect'

class Parser

  # @param source [IO] The data file, etc. to read.
  def initialize(source)
    @source = source
  end

  # @return [Array<Constraint>]
  def constraints
    @constraints ||= (explicit_constraints + implied_constraints)
  end

  # @return [Array<BuildOption>]
  def build_options
    @build_options ||= parsed_data['build_options'].map do |option|

      BuildOption.new(option['name'],
                      parse_effects(option),
                      parse_choices(option['choices']))
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

  # @param choice_data [Array<Hash>, NilClass]
  # @return [Array<BuildOption::Choice>, NilClass]
  def parse_choices(choice_data)
    if choice_data.nil?
      return nil
    end

    choice_data.map do |choice|
      choice_effects = parse_effects(choice) || []
      BuildOption::Choice.new(choice['name_suffix'], choice_effects)
    end
  end
end
