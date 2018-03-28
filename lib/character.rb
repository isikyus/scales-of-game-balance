# A character built from a given set of choices.
# As well as the genome (what choices were made),
# this means specifying what stats you ended up with.

class Character

  # @param genome [Genome] The build decisions made to create this character.
  # @param stats [Hash] The final stats (and used resources) of the character.
  # @param given_name [String] a name for this character.
  # @param family_name [String] a name indicating this character's ancestry.
  def initialize(genome, stats, given_name, family_name='' )
    @genome = genome
    @stats = stats
    @given_name = given_name
    @family_name = family_name
  end

  attr_reader :genome, :stats, :given_name, :family_name

  def inspect
    indented_genome = '  ' + genome.inspect.gsub("\n", "\n  ")
    "<#Character '#{full_name}':\n  @genome = \n#{indented_genome}\n  @stats = #{stats.inspect}>"
  end

  def full_name
    "#{given_name} #{family_name}"
  end
end
