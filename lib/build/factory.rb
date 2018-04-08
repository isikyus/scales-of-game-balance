
# Knows how to apply build choices while respecting constraints,
# to turn a random genome-list of choices into something that can
# legally be used as a character (albeit potentially missing some feats, etc.)

require 'lib/build'

class Build::Factory

  # @param constraints [Array<ResourceConstraint>] The constraints within which to build
  def initialize(constraints)
    @constraints = constraints
  end

  # Just run through the list of build choices, accepting all
  # until we run out of resources.
  # This isn't perfect (what about pre-requisites satisified 
  # by a later choice, or later choices that restore resources?),
  # but it is at least determinisitic,
  # which is good enough for now.
  #
  # @param raw_build_choices [Array<BuildOption>]
  def build(raw_build_choices)

    resources_left = {}.tap do |res|
      @constraints.each do |constraint|

        # May be multiple constraints per resource (e.g. minimum and maximum),
        # but we only need one hash value for each.
        res[constraint.resource] = 0
      end
    end

    valid_choices = raw_build_choices.inject([]) do |chosen, choice|

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

    Build.new(resources_left, valid_choices)
  end
end
