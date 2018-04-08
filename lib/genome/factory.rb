
# Knows how to create new Genome objects randomly.
# TODO: Some overlap with Genome::Reproducer

require 'lib/genome'

class Genome::Factory

  # @param build_options [Array] valid elements to add to the genome.
  # @param length [Integer] The length of the new genomes to create.
  # @param random [Random] dependency-injected random number generator to use.
  def initialize(build_options, length, random=Random.new)
    @build_options = build_options
    @length = length
    @random = random
  end

  # Create a new genome randomly, using the given data.
  def random_genome
    Genome.new(@length.times.map { random_build_option })
  end

  private

  # Chose a build option at random,
  # including randomly making any required choices.
  def random_build_option
    option = @build_options.sample(random: @random)

    # If the option has choices not yet made, make them.
    # TODO: might need to be recursive?
    if option.choices
      option.choose(option.choices.sample(random: @random))
    else
      option
    end
  end
end
