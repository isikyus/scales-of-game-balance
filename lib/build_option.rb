
# An option that can be taken when creating a character.

class BuildOption

  # TODO: create a subclass/side-class for options not yet fully decided.
  Choice = Struct.new(:name_suffix, :effects)

  # Create a build option with data loaded from a data file
  # @param name [String] Name of this build option
  # @param effects [Array<Effect>] Details of this build option's effects,
  #                                 excluding choices not yet made.
  # @param choices [Array<Choice>,NilClass] Details of choices this option offers
  #                                         that are not yet made -- if any.
  def initialize(name, effects=[], choices=nil)
    @name = name
    @effects = effects
    @choices = choices
  end

  attr_reader :name, :choices, :effects

  # True if there are no more choices to be made for this particular build option.
  def concrete?
    choices.nil?
  end

  # Return a new BuildOption with a specific value for a choice offered by this
  # option (e.g. which stat to modify)
  # Pass in a specific effect from the choices this build option offers.
  #
  # @param choice [Choice]
  def choose(choice)
    raise "Unknown choice #{choice.inspect}" unless choices.include?(choice)

    new_name = name + choice.name_suffix
    new_effects = effects + choice.effects
    BuildOption.new(new_name, new_effects)
  end

  def inspect
    text = "<#BuildOption #{name}: #{effects.inspect}"
    text << " yet to be chosen: #{choices.inspect}" if choices
    text << '>'
  end
end
