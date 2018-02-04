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
    @constraints ||= parsed_data['resources'].map do |resource|
      Constraint.new(resource['name'], maximum: resource['maximum'])
    end
  end

  # @return [Array<BuildOption>]
  def build_options
    @build_options ||= parsed_data['build_options'].map do |option|

      BuildOption.new(option['name'],
                      parse_effects(option['effects']),
                      parse_choices(option['choices']))
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

  # @param choice_data [Array<Hash>, NilClass]
  # @return [Array<BuildOption::Choice>, NilClass]
  def parse_choices(choice_data)
    if choice_data.nil?
      return nil
    end

    choice_data.map do |choice|
      choice_effects = parse_effects(choice['effects']) || []
      BuildOption::Choice.new(choice['name_suffix'], choice_effects)
    end
  end
end
