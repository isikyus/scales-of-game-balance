# Calculates the effect of one generation of adventuring -- who
# survives, and what their children look like.
class RunGeneration

  class ExtinctionError < StandardError
  end

  # @param scorer An object that returns comparable values
  #               in response to #score; used to pick the fittest.
  # @param reproducer An object that defines #child(parent1, parent2);
  #                   used to create new individuals.
  # @param survival_rate [Float] A number between 0 and 1; the
  #                       proportion of the existing population to keep.
  # @param random [Random] the random number generator in use.
  def initialize(scorer, reproducer, survival_rate, random=Random.new)
    @scorer = scorer
    @reproducer = reproducer
    @survival_rate = survival_rate
    @random = random
  end

  # Returns a new population (set of individuals)
  # descended from the input.
  # @param population [Array<Character>]
  # @return [Array<Character>]
  def call(population)

    # Find the fittest members of the population.
    survivors = @survival_rate * population.length

    raise ExtinctionError if survivors.zero?

    fittest = population.max_by(survivors) do |individual|
      @scorer.score(individual)
    end

    # Fill up the rest of the population with children of the fittest.
    children = (population.length - fittest.length).times.map do

      # Sample twice rather than calling fittest.sample(2),
      # since we want to allow repeated elements.
      parents = 2.times.map { fittest.sample(random: @random) }
      @reproducer.child(*parents)
    end

    fittest + children
  end
end
