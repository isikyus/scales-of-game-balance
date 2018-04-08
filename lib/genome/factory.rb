
# Knows how to create new Genome objects randomly.
# TODO: Some overlap with Genome::Reproducer

require 'lib/genome'
require 'lib/genome/random_build_option'

class Genome::Factory

  # @param build_options [Array] valid elements to add to the genome.
  # @param length [Integer] The length of the new genomes to create.
  # @param random [Random] dependency-injected random number generator to use.
  def initialize(build_options, length, random=Random.new)
    @random_option = Genome::RandomBuildOption.new(build_options, random)
    @length = length
    @random = random
  end

  # Create a new genome randomly, using the given data.
  def random_genome
    random_options = @length.times.map { @random_option.call }
    Genome.new(random_options)
  end
end
