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
GENOME_LENGTH = 5
@population = POPULATION_SIZE.times.map do
  Genome.new_randomised(GENOME_LENGTH, parser.build_options)
end

# Handy methods. TODO: build a class for this.
def print_population
  @population.each do |build|
    p build
    puts "After applying constraints:"
    p @character_factory.build_character(build)
  end
end

# Output the starting population
print_population

# TODO: Score population

# TODO: Have highest-scoring individuals reproduce

# TODO: Mutate some individuals randomly
