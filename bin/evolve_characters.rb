# Evolve new randomly-generated characters

USAGE_MESSAGE = "Usage: ruby #{$1}"

app_dir = File.dirname(File.dirname(File.realdirpath(__FILE__)))
$: << "#{app_dir}"
require 'lib/genome'
require 'lib/parser'
require 'lib/name_generator'
require 'lib/character_factory'
require 'lib/run_generation'
require 'lib/reproducer'
require 'lib/scorers/maximum_stat_scorer'

require 'yaml'

# Load game system data tables.
data_file = File.new(File.join(app_dir, 'ogl', 'sample.yml'))
parser = Parser.new(data_file)

@random = Random.new
@character_factory = CharacterFactory.new(parser.constraints)
@name_generator = NameGenerator.new

# Generate some random characters
POPULATION_SIZE = 20
GENOME_LENGTH = 10
@population = POPULATION_SIZE.times.map do
  genome = Genome.new_randomised(GENOME_LENGTH, parser.build_options)
    name = @name_generator.call
  @character_factory.build_character(genome, name)
end

@scorer = MaximumStatScorer.new

# Handy methods. TODO: build a class for this.
def print_population(details = false)
  @population.each do |character|
    p character
    puts "#{character.full_name} scores #{@scorer.score(character)}"
  end
end

# Output the starting population
puts "Initial population:"
print_population

# Have highest-scoring individuals reproduce
ITERATIONS = 10
SURVIVAL_RATE = 0.1
MUTATION_CHANCE = 0.05

@reproducer = Reproducer.new(parser.build_options,
                             @name_generator,
                             @character_factory,
                             MUTATION_CHANCE,
                             @random)
@generation_runner = RunGeneration.new(@scorer, @reproducer, SURVIVAL_RATE, @random)

ITERATIONS.times do |iteration|
  puts
  puts "Iteration #{iteration + 1}:"

  @population = @generation_runner.call(@population)

  print_population
end
