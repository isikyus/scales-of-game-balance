# Evolve new randomly-generated characters

USAGE_MESSAGE = "Usage: ruby #{$1}"

app_dir = File.dirname(File.dirname(File.realdirpath(__FILE__)))
$: << "#{app_dir}"
require 'lib/genome'
require 'lib/parser'
require 'lib/character_factory'
require 'lib/name_generator'

require 'yaml'

# Load game system data tables.
data_file = File.new(File.join(app_dir, 'ogl', 'pathfinder.yml'))
parser = Parser.new(data_file)

@character_factory = CharacterFactory.new(parser.constraints)
@name_generator = NameGenerator.new

# Generate some random characters
POPULATION_SIZE = 20
GENOME_LENGTH = 10
@population = POPULATION_SIZE.times.map do
  Genome.new_randomised(GENOME_LENGTH, parser.build_options)
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
def print_population
  @population.each do |build|
    name = @name_generator.call
    character = @character_factory.build_character(build, name)
    p character
    puts "Score: #{score_character(character)}"
  end
end

# Output the starting population
print_population

# TODO: Have highest-scoring individuals reproduce

# TODO: Mutate some individuals randomly
