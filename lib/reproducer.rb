
# Create a new character build based on two given parents.

class Reproducer

  # Prefix applied to a given name to turn it into a surname.
  CHILD_OF = 'nic'

  # @param name_generator [NameGenerator] for generating names for child characters.
  # @param character_factory [CharacterFactory] to create Character objects. TODO: shouldn't need this if we do build calculations separately.
  # @param random [Random] dependency-injected random number generator to use.
  def initialize(name_generator, character_factory, random=Random.new)
    @name_generator = name_generator
    @character_factory = character_factory
    @random = random
  end

  # Build a new character with a genome based on two existing ones,
  # and a newly-generated name.
  #
  # @param parent1 [Character] one existing character to work from.
  # @param parent2 [Character] the other existing character to work from. TODO: actually use
  # @return [Character] the "child" character.
  def child(parent1, parent2)
    new_genome = Genome.mutate(parent1.genome)
    given_name = @name_generator.call
    surname = "#{CHILD_OF} #{parent1.given_name}"
    @character_factory.build_character(new_genome, given_name, surname)
  end
end
