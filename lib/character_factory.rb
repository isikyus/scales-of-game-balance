
# Create a specific character build, by applying the
# decisions in a genome to within the limits of the game
# system (e.g. feat counts pre-requisites) and power level
# (e.g. number of class levels, or points limit).

require 'lib/genome'
require 'lib/character'
require 'lib/build/factory'

class CharacterFactory

  # The surname to use for randomly-generated characters (with no ancestors).
  NEW_LINEAGE_SURNAME = 'First-of-That-Line'

  # @param build_factory [BuildFactory]
  def initialize(build_factory)
    @build_factory = build_factory
  end

  # Create a new character with no ancestry information.
  #
  # @param genome [Genome] the build choices we want to make.
  # @param name [String] a name for the new character.
  # @param surname [String] optional second name to indicate ancestry.
  # @return [Character]
  def build_character(genome, name, surname=NEW_LINEAGE_SURNAME)
    Character.new(genome,
                  @build_factory.build(genome.build_choices).stats,
                  name,
                  surname)
  end
end
