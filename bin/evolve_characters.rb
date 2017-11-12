# Evolve new randomly-generated characters

USAGE_MESSAGE = "Usage: ruby #{$1}"

require_relative '../lib/genome'
require_relative '../lib/build_option'

require 'yaml'

# Load game system data tables.
app_dir = File.dirname(File.dirname(File.realdirpath(__FILE__)))
data_file_path = File.join(app_dir, 'ogl', 'pathfinder.yml')
data = YAML.load_file(data_file_path)

p data_file_path
p data

build_options = data['build_options'].map do |build_option|
  BuildOption.new(build_option['name'], build_option['effects'], build_option['choices'])
end

# Generate some random characters
POPULATION_SIZE = 20
GENOME_LENGTH = 5
@population = POPULATION_SIZE.times.map do
  Genome.new_randomised(GENOME_LENGTH, build_options)
end

# Handy methods. TODO: build a class for this.
def print_population
  puts @population.map(&:inspect)
end

# Output the starting population
print_population

# TODO: Score population

# TODO: Have highest-scoring individuals reproduce

# TODO: Mutate some individuals randomly
