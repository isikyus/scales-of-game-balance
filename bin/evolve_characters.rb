# Evolve new randomly-generated characters

USAGE_MESSAGE = "Usage: ruby #{$1}"

require_relative '../lib/genome'
require_relative '../lib/build_option'
require_relative '../lib/constraint'
require_relative '../lib/character_factory'

require 'yaml'

# Load game system data tables.
app_dir = File.dirname(File.dirname(File.realdirpath(__FILE__)))
data_file_path = File.join(app_dir, 'ogl', 'pathfinder.yml')
data = YAML.load_file(data_file_path)

# TODO: temove or put behind option.
p data_file_path
p data

build_options = data['build_options'].map do |build_option|
  effects = if build_option['effects']
    BuildOption::Effect.from_array(build_option['effects'])
  else
    nil
  end
  BuildOption.new(build_option['name'], effects, build_option['choices'])
end

constraints = data['resources'].map do |resource|
  Constraint.new(resource: resource['name'].to_sym,
                 maximum: resource['maximum'])
end
@character_factory = CharacterFactory.new(constraints)

# Generate some random characters
POPULATION_SIZE = 20
GENOME_LENGTH = 5
@population = POPULATION_SIZE.times.map do
  Genome.new_randomised(GENOME_LENGTH, build_options)
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
