# A constraint on how characters can be built.
# Defined as a named (symbol) "resource", and a numeric
# limit on its value.

class Constraint

  # TODO: use named parameters.
  def initialize(resource, limits)
    @resource = resource

    # TODO: allow other constraints -- maybe use dry-validation or some such?
    @maximum = limits[:maximum] || raise
  end

  attr_accessor :resource

  # Check whether the given value for this resource is valid given this constraint.
  def satisfied?(value)
    value <= @maximum
  end

  def limits
    { maximum: @maximum }
  end
end
