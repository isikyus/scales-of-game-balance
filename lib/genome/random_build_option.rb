# TODO: not sure this functionality belongs in genome code.

require 'lib/genome'

class Genome::RandomBuildOption

  # @param build_options [Array<BuildOption>] The options to choose from.
  # @param random [Random] dependency-injected random number generator to use.
  def initialize(build_options, random=Random.new)
    @build_options = build_options
    @random = random
  end

  # Chose a build option at random,
  # including randomly making any required choices.
  def call

    option = @build_options.sample(random: @random)

    # If the option has choices not yet made, make them.
    # TODO: might need to be recursive?
    if option.concrete?
      option
    else
      option.choose(option.choices.sample(random: @random))
    end
  end
end
