
# The genome of a build is a sequence of build decisions
# (levels, feats, class options, etc)
# We don't care about validity of the build when generating a genome; 
# we'll check all that when we put together the character.

# TODO: rename to Build, and extract Genome to its own model.
class Genome

  # Create a genome of the given length, chosing build options from the given list.
  def self.new_randomised(length, build_options) 
    new(length.times.map { random_build_option(build_options) })
  end

  # Create a genome using the given list of build choices.
  # @param build_choices [Array<BuildOption>]
  def initialize(build_choices)

    unless build_choices.all? { |choice| choice.choices.nil? }
      raise "#{build_choices} includes options not fully specified"
    end

    @build_choices = build_choices
  end

  attr_accessor :build_choices

  def inspect
    build_choice_strings = @build_choices.map(&:inspect)
    indented_choices = build_choice_strings.map do |choice|
      '  ' + choice
    end

    [
      '<Genome @build_choices = ',
      *indented_choices,
      '>'
    ].join("\n")
  end

  # Chose a build option from the given list, completely at random.
  def self.random_build_option(build_options)
    option = build_options.sample

    # If the option has choices not yet made, make them.
    # TODO: might need to be recursive?
    if option.choices
      option.choose(option.choices.sample)
    else
      option
    end
  end
end
