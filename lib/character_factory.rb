
# Create a specific character build, by applying the
# decisions in a genome to within the limits of the game
# system (e.g. feat counts pre-requisites) and power level
# (e.g. number of class levels, or points limit).

require_relative 'genome'

class CharacterFactory < Genome

  # @param constraints [Array<ResourceConstraint>] The constraints within which to build the character.
  def initialize(constraints)
    @constraints = constraints
  end

  # @param build [Genome] the build choices we want to make.
  # @return [Genome] TODO should return a subclass of Build that can do stat calculations.
  def build_character(genome)
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
    # by a later choice, or later choices that restore resources), but it is at least determinisitic,
    # which is good enough for now.
    valid_build_choices = genome.build_choices.inject([]) do |chosen, choice|

      # What resources would we have left if we applied this change?
      resources_after_choice = resources_left.dup
      choice.effects_array.each do |effect|
        if effect.key?('resource')
          resources_after_choice[effect.resource] += effect.change
        end
      end

      # Accept the choice unless the new resources violate the constraints.
      accept_choice = @constraints.all? do |constraint|
         value = resources_after_choice[constraint.resource]
         constraint.satisfied?(value)
      end

      if accept_choice
        resources_left = resources_after_choice
        chosen.push(choice)
      else

        # Can't choose this, so just keep going.
        chosen
      end
    end

    Genome.new(valid_build_choices)
  end
end
