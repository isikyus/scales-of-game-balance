
# An option that can be taken when creating a character.

class BuildOption

  # TODO: create a subclass/side-class for options not yet fully decided.
  Choice = Struct.new(:name_suffix, :effects)

  # Create a build option with data loaded from a data file
  # @param name [String] Name of this build option
  # @param effects [Array<Effect>,NilClass] Details of this build option's effects.
  #                        May be nil if not all choices made.
  # @param choices [Array<Choice>,NilClass] Details of choices this option offers that are not yet made.
  def initialize(name, effects=nil, choices=nil)
    @name = name
    @effects = effects
    @choices = choices
  end

  attr_reader :name, :choices, :effects

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
