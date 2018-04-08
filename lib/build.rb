
# The result of applying a given set of build choices:
# what choices you were able to make (e.g. how many of the point buy stats
# in the genome you could actually afford), and what stats you ended up with.

class Build

  # @param stats [Hash{String,Numeric}]
  # @param choices [Array<BuildChoice>] Should all be concrete build choices.
  def initialize(stats, choices)

    unless choices.all?(&:concrete?)
      raise "A build must be based on fully-detailed choices"
    end

    @stats = stats
    @choices = choices
  end

  attr_accessor :stats, :choices
end
