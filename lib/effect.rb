# A specific effect of a build option on some stat.
# TODO: distinguish effects on resources and stats? Or combine the two?
# Abstract -- to be overridden by subclasses.
class Effect

  # [S] The resource this effect applies  to
  attr_reader :resource

  # Calculate the new value of the resource (or stat)
  # after applying this effect.
  # TODO: support non-integer values
  # TODO: is Effect an action or data class?
  # @param old_value [Fixnum, Nil] the previous value, if any.
  # @return [Fixnum, Nil] The value after applying this effect.
  def new_value(old_value)
    raise 'to be implemented in subclass'
  end

  class Change < Effect
    def initialize(resource, change)
      @resource = resource
      @change = change
    end

    attr_reader :change

    def new_value(old_value)
      old_value + change
    end

    def inspect
      "<#{resource} += #{change}>"
    end
  end

  class SetValue < Effect
    def initialize(resource, value_to_set)
      @resource = resource
      @value_to_set = value_to_set
    end

    attr_reader :value_to_set

    def new_value(old_value)
      value_to_set
    end

    def inspect
      "<#{resource} = #{value_to_set}>"
    end
  end
end
