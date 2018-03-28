require 'lib/genome'

# Create a new genome (build) based on two given parents.

class Genome::Reproducer

  # @param build_options [Array] valid elements to add to the genome.
  # @param mutation_chance [Float] The chance of _one_ mutation when a genome is copied.
  #                                 This is applied until it fails, so a rate of 0.5
  #                                 gives you one mutation in 0.5 - 0.25 = 25% of children,
  #                                 two in 0.25 - 0.125 = 125% of children, and so on.
  # @param random [Random] dependency-injected random number generator to use.
  def initialize(build_options, mutation_chance, random=Random.new)
    @build_options = build_options
    @mutation_chance = mutation_chance
    @random = random
  end

  # Build a new genome based on two existing ones.
  #
  # @param parent1 [Genome] one existing genome to work from.
  # @param parent2 [Genome] the other existing genome to work from. TODO: actually use
  # @return [Genome] the "child" genome.
  def child(parent1, parent2)

    # TODO: inject Genome as a dependency.
    Genome.new(mutate(parent1.build_choices))
  end

  # Create a new genome similar to the given one, but with slight random changes.
  #
  # @param original [Array<BuildOption>]
  # @return [Array<BuildOption>]
  # TODO: only public for testing.
  def mutate(original)

    # Randomly decide how many mutations to apply.
    # We cap the number at genome length to avoid running forever.
    mutations = 0
    max_mutations = original.length
    while (mutations < max_mutations) && (@random.rand < @mutation_chance)
      mutations += 1
    end

    # Apply those mutations.
    new_choices = original.dup
    mutations.times do
      apply_mutation!(new_choices)
    end

    new_choices
  end

  private

  # Apply a single (randomly-chosen) mutation to the given genome,
  # modifying the original.
  # @param genome [Genome]
  def apply_mutation!(genome)

    mutationIndex = @random.rand(genome.length)

    # 50-50 chance of adding or removing elements.
    if @random.rand < 0.5
      new_choice = Genome.random_build_option(@build_options)
      genome.insert(mutationIndex, new_choice)
    else
      genome.delete_at(mutationIndex)
    end
  end
end
