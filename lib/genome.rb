
# The genome of a build is a sequence of build decisions
# (levels, feats, class options, etc)
# To calculate the stats of the actual buid, we go through the list
# applying all options in turn. Once a resource runs out (e.g. skill ranks,
# feat slots, or levels), we stop applying changes that depend on that resource;
# so a first-level Commoner genome might list three feats, but we'll only apply
# the first one or two.

class Genome

  # Create a genome of the given length, chosing build options from the given list.
  def self.new_randomised(length, build_options) 
    new(length.times.map { random_build_option(build_options) })
  end

  # Create a genome using the given list of build choices.
  # @param build_choices [Array<BuildOption>]
  def initialize(build_choices)

    unless build_choices.all? { |choice| choice.choices.nil? }
      raise "#{build_choices} includes options not fully specified"
    end

    @build_choices = build_choices
  end

  def inspect
    "<Genome @build_choices=#{@build_choices.inspect}>"
  end

  # Chose a build option from the given list, completely at random.
  def self.random_build_option(build_options)
    option = build_options.sample

    # If the option has choices not yet made, make them.
    # TODO: might need to be recursive?
    if option.choices
      option.choose(option.choices.sample)
    else
      option
    end
  end
end
