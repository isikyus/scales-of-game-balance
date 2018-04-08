# Evolve new randomly-generated characters

app_dir = File.dirname(File.dirname(File.realdirpath(__FILE__)))
$: << "#{app_dir}"
require 'lib/genome'
require 'lib/parser'
require 'lib/name_generator'
require 'lib/character_factory'
require 'lib/run_generation'
require 'lib/character/reproducer'
require 'lib/genome/reproducer'
require 'lib/scorers/maximum_stat_scorer'

require 'optparse'
require 'yaml'

# Default options for applying the genetic algorithm.
algorithm_parameters = {
  population: 20,
  starting_genome_length: 10,
  generations: 10,
  survival_rate: 0.1,
  mutation_chance: 0.05
}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby #{$1} [options]"

  opts.on('-p', '--population POPULATION', Integer,
          'Number of organisms in each generation') do |population|
    algorithm_parameters[:population] = population
  end

  opts.on('--genome-size SIZE', Integer,
          'Starting number of build choices in each genome; may change by mutations') do |genome_length|
    algorithm_parameters[:starting_genome_length] = genome_length
  end

  opts.on('-g', '--generations COUNT', Integer,
          'Number of generations to run for') do |generations|
    algorithm_parameters[:generations] = generations
  end

  opts.on('-s', '--survival_rate RATE', Float,
          'Proportion of characters selected as parents of the next generation') do |survival|
    algorithm_parameters[:survival_rate] = survival
  end

  opts.on('-m', '--mutation_chance CHANCE', Float,
          'Chance of a single mutation on reproducing. '\
          'Applies recursively, so if it\'s 0.1, 1 in 10 organisms will mutate '\
          'at least once, 1 in 100 at least twice, and so on') do |mutation_chance|
    algorithm_parameters[:mutation_chance] = mutation_chance
  end
end.parse!

# Load game system data tables.
data_file = File.new(File.join(app_dir, 'ogl', 'sample.yml'))
parser = Parser.new(data_file)

@random = Random.new
@character_factory = CharacterFactory.new(parser.constraints)
@name_generator = NameGenerator.new

# Generate some random characters
@population = algorithm_parameters[:population].times.map do
  genome = Genome.new_randomised(algorithm_parameters[:starting_genome_length],
                                 parser.build_options)
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
genome_reproducer = Genome::Reproducer.new(parser.build_options,
                                           algorithm_parameters[:mutation_chance],
                                           @random)
reproducer = Character::Reproducer.new(@name_generator,
                                       genome_reproducer,
                                       @character_factory)
@generation_runner = RunGeneration.new(@scorer,
                                       reproducer,
                                       algorithm_parameters[:survival_rate],
                                       @random)

begin
  algorithm_parameters[:generations].times do |generation|
    puts
    puts "Iteration #{generation + 1}:"

    @population = @generation_runner.call(@population)

    print_population
  end

rescue RunGeneration::ExtinctionError
  $stderr.puts 'The population has gone extinct! Not enough survived to produce a new generation.'
  $stderr.puts 'Try increasing the survival rate, or using a larger population'
end
