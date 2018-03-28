# Evolve new randomly-generated characters

USAGE_MESSAGE = "Usage: ruby #{$1}"

app_dir = File.dirname(File.dirname(File.realdirpath(__FILE__)))
$: << "#{app_dir}"
require 'lib/genome'
require 'lib/parser'
require 'lib/character_factory'

require 'yaml'

# Load game system data tables.
data_file = File.new(File.join(app_dir, 'ogl', 'pathfinder.yml'))
parser = Parser.new(data_file)

@character_factory = CharacterFactory.new(parser.constraints)

# Generate some random characters
POPULATION_SIZE = 20
GENOME_LENGTH = 10
@population = POPULATION_SIZE.times.map do
  genome = Genome.new_randomised(GENOME_LENGTH, parser.build_options)
  @character_factory.build_character(genome)
end

def score_character(character)
  # TODO: make objective functions configurable.

  # Just use the maximum stat -- let's see if the algorithm can work out how to get an 18.
  ability_scores = character.stats.select do |stat, _|
    stat.end_with?('score')
  end
  ability_scores.map { |_, score| score }.max
end

# Handy methods. TODO: build a class for this.
    p character
def print_population(details = false)
  @population.each do |character|
    puts "Score: #{score_character(character)}"
  end
end

# Output the starting population
puts "Initial population:"
print_population

# Have highest-scoring individuals reproduce
ITERATIONS = 10
SURVIVAL_RATIO = 0.1
SURVIVORS = POPULATION_SIZE * SURVIVAL_RATIO

ITERATIONS.times do |iteration|
  puts
  puts "Iteration #{iteration + 1}:"

  # Find the fittest members of the population.
  fittest = @population.sort_by { |char| score_character(char) }.first(SURVIVORS)

  # Fill up the rest of the population with children of the fittest.
  children = (POPULATION_SIZE - fittest.length).times.map do
    @character_factory.child(fittest.sample)
  end
  
  @population = fittest + children

  print_population
end
