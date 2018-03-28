# Minimal implementation -- score characters based on their highest stat.
class MaximumStatScorer
  def score(character)
    ability_scores = character.stats.select do |stat, _|
      stat.end_with?('score')
    end
    ability_scores.map { |_, score| score }.max
  end
end
