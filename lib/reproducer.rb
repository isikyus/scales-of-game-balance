
# Create a new character build based on two given parents.

class Reproducer

  # Prefix applied to a given name to turn it into a surname.
  CHILD_OF = 'nic'

  # @param build_options [Array] valid elements to add to the genome.
  # @param name_generator [NameGenerator] for generating names for child characters.
  # @param character_factory [CharacterFactory] to create Character objects. TODO: shouldn't need this if we do build calculations separately.1
  # @param mutation_chance [Float] The chance of _one_ mutation when a genome is copied.
  #                                 This is applied until it fails, so a rate of 0.5
  #                                 gives you one mutation in 0.5 - 0.25 = 25% of children,
  #                                 two in 0.25 - 0.125 = 125% of children, and so on.
  # @param random [Random] dependency-injected random number generator to use.
  def initialize(build_options, name_generator, character_factory, mutation_chance, random=Random.new)
    @build_options = build_options
    @name_generator = name_generator
    @character_factory = character_factory
    @mutation_chance = mutation_chance
    @random = random
  end

  # Build a new character with a genome based on two existing ones,
  # and a newly-generated name.
  #
  # @param parent1 [Character] one existing character to work from.
  # @param parent2 [Character] the other existing character to work from. TODO: actually use
  # @return [Character] the "child" character.
  def child(parent1, parent2)
    new_genome = mutate(parent1.genome)
    given_name = @name_generator.call
    surname = "#{CHILD_OF} #{parent1.given_name}"
    @character_factory.build_character(new_genome, given_name, surname)
  end

  private

  # Create a new genome similar to the given one, but with slight random changes.
  #
  # @param original [Genome]
  # @return [Genome]
  def mutate(original)

    # Randomly decide how many mutations to apply.
    # We cap the number at genome length to avoid running forever.
    mutations = 0
    max_mutations = original.build_choices.length
    while (mutations < max_mutations) && (@random.rand < @mutation_chance)
      mutations += 1
    end

    # Apply those mutations.
    new_choices = original.build_choices.dup
    mutations.times do
      apply_mutation!(new_choices)
    end

    # TODO: inject Genome as a dependency.
    Genome.new(new_choices)
  end

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
