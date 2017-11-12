
# An option that can be taken when creating a character.

class BuildOption

  Choice = Struct.new(:name_suffix, :effects)

  # Create a build option with data loaded from a data file
  # @param name [String] Name of this build option
  # @param effects [Array,NilClass] Details of this build option's effects.
  #                        May be nil if not all choices made.
  # @param choices [Array,NilClass] Details of choices this option offers that are not yet made.
  def initialize(name, effects, choices=nil)
    @name = name
    @effects = effects || []
    
    if choices
      @choices = choices.map do |choice|
        # TODO: doing parsing here that should be done when we load the file.
        Choice.new(choice['name_suffix'], choice['effects'])
      end
    end
  end

  attr_accessor :name, :choices, :effects

  # Return a new BuildOption with a specific value for a choice offered by this
  # option (e.g. which stat to modify)
  # Pass in a specific effect from the choices this build option offers.
  #
  # @param choice [Choice]
  def choose(choice)
    raise "Unknown choice #{choice}" unless choices.include?(choice)

    BuildOption.new(name + choice.name_suffix, effects + choice.effects)
  end

  def inspect
    text = "<#BuildOption #{name}: #{effects.inspect}"
    text << " yet to be chosen: #{choices.inspect}" if choices
    text << '>'
  end
end
