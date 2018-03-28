
# Create a new character build based on two given parents.
require 'lib/character'

class Character::Reproducer

  # Prefixes applied to parents' given names to create a surname
  LEFT_CHILD_OF = 'ic'
  RIGHT_CHILD_OF = 'ac'

  # @param name_generator [NameGenerator] for generating names for child characters.
  # @param genome_reproducer object that can handle reproduction of Genome objects
  # @param character_factory [CharacterFactory] to create Character objects. TODO: shouldn't need this if we do build calculations separately.
  def initialize(name_generator, genome_reproducer, character_factory)
    @name_generator = name_generator
    @genome_reproducer = genome_reproducer
    @character_factory = character_factory
  end

  # Build a new character with a genome based on two existing ones,
  # and a newly-generated name.
  #
  # @param parent1 [Character] one existing character to work from.
  # @param parent2 [Character] the other existing character to work from. TODO: actually use
  # @return [Character] the "child" character.
  def child(parent1, parent2)
    new_genome = @genome_reproducer.child(parent1.genome, parent2.genome)
    given_name = @name_generator.call
    surname = "#{LEFT_CHILD_OF} #{parent1.given_name} #{RIGHT_CHILD_OF} #{parent2.given_name}"
    @character_factory.build_character(new_genome, given_name, surname)
  end
end
