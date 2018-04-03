
# Create a specific character build, by applying the
# decisions in a genome to within the limits of the game
# system (e.g. feat counts pre-requisites) and power level
# (e.g. number of class levels, or points limit).

require 'lib/genome'
require 'lib/character'

class CharacterFactory

  # The surname to use for randomly-generated characters (with no ancestors).
  NEW_LINEAGE_SURNAME = 'First-of-That-Line'

  # @param constraints [Array<ResourceConstraint>] The constraints within which to build the character.
  def initialize(constraints)
    @constraints = constraints
  end

  # Create a new character with no ancestry information.
  #
  # @param genome [Genome] the build choices we want to make.
  # @param name [String] a name for the new character.
  # @param surname [String] optional second name to indicate ancestry.
  # @return [Character]
  def build_character(genome, name, surname=NEW_LINEAGE_SURNAME)
    resources_left = {}.tap do |res|
      @constraints.each do |constraint|

        # May be multiple constraints per resource (e.g. minimum and maximum),
        # but we only need one hash value for each.
        res[constraint.resource] = 0
      end
    end

    # Just run through the list of build choices, accepting all
    # until we run out of resources.
    # This isn't perfect (what about pre-requisites satisified 
    # by a later choice, or later choices that restore resources?),
    # but it is at least determinisitic,
    # which is good enough for now.
    # TODO: calculating build choices should probably be its own class
    valid_build_choices = genome.build_choices.inject([]) do |chosen, choice|

      # What resources would we have left if we applied this change?
      after_choice = resources_left.dup
      choice.effects.each do |effect|
        after_choice[effect.resource] = effect.new_value(after_choice[effect.resource])
      end

      # Accept the choice unless the new resources violate the constraints.
      accept_choice = @constraints.all? do |constraint|
         value = after_choice[constraint.resource]
         constraint.satisfied?(value)
      end

      if accept_choice
        resources_left = after_choice
        chosen.push(choice)
        chosen
      else

        # Can't choose this, so just keep going.
        chosen
      end
    end

    Character.new(genome, resources_left, name, surname)
  end
end
