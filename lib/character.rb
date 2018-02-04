# A character built from a given set of choices.
# As well as the genome (what choices were made),
# this means specifying what stats you ended up with.

class Character

  # @param genome [Genome] The build decisions made to create this character.
  # @param stats [Hash] The final stats (and used resources) of the character.
  def initialize(genome, stats)
    @genome = genome
    @stats = stats
  end

  attr_reader :genome, :stats

  def inspect
    indented_genome = '  ' + genome.inspect.gsub("\n", "\n  ")
    "<#Character: @genome = \n#{indented_genome}\n  @stats = #{stats.inspect}>"
  end
end
