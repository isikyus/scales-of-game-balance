
# An option that can be taken when creating a character.

class BuildOption

  # TODO: create a subclass/side-class for options not yet fully decided.
  Choice = Struct.new(:name_suffix, :effects)

  # A specific effect of a build option on some stat.
  # TODO: distinguish effects on resources and stats? Or combine the two?
  class Effect

    def self.from_hash_array(effect_data)

      # TODO: extract parser?
      effect_data.map do |data|
        Effect.new(data)
      end
    end

    def initialize(data)
      @resource = data['resource'] && data['resource'].to_sym
      @change = data['change'].to_i
    end

    attr_accessor :resource, :change
  end

  # Create a build option with data loaded from a data file
  # @param name [String] Name of this build option
  # @param effects [Array<Effect>,NilClass] Details of this build option's effects.
  #                        May be nil if not all choices made.
  # @param choices [Array,NilClass] Details of choices this option offers that are not yet made.
  def initialize(name, effects, choices=nil)
    @name = name

    if choices
      @choices = choices.map do |choice|
        # TODO: doing parsing here that should be done when we load the file.
        choice_effects = (choice['effects'] || []).map do |data|
          Effect.new(data)
        end

        Choice.new(choice['name_suffix'], choice_effects)
      end
    end
  end

  attr_accessor :name, :choices, :effects

  # Like #effects, but returns an empty array rather than nil if no effects.
  def effects_array
    effects || []
  end

  # Return a new BuildOption with a specific value for a choice offered by this
  # option (e.g. which stat to modify)
  # Pass in a specific effect from the choices this build option offers.
  #
  # @param choice [Choice]
  def choose(choice)
    raise "Unknown choice #{choice}" unless choices.include?(choice)

    new_name = name + choice.name_suffix
    new_effects = effects_array + choice.effects
    BuildOption.new(new_name, new_effects)
  end

  def inspect
    text = "<#BuildOption #{name}: #{effects.inspect}"
    text << " yet to be chosen: #{choices.inspect}" if choices
    text << '>'
  end
end
