# A constraint on how characters can be built.
# Defined as a named (symbol) "resource", and a numeric
# limit on its value.

class Constraint

  # TODO: use named parameters.
  def initialize(options)
    @resource = options[:resource] || raise

    # TODO: allow other constraints -- maybe use dry-validation or some such?
    @maximum = options[:maximum] || raise
  end

  attr_accessor :resource

  # Check whether the given value for this resource is valid given this constraint.
  def satisfied?(value)
    value < @maximum
  end
end
