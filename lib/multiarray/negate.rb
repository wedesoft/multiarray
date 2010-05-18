module Hornetseye

  class Negate < Node

    def initialize( value )
      @value = value
    end

    def inspect
      "-(#{@value.inspect})"
    end

    def descriptor( hash )
      "-(#{@value.descriptor( hash )})"
    end

    def array_type
      @value.array_type
    end

    def subst( hash )
      Negate.new @value.subst( hash )
    end

    def variables
      @value.variables
    end

    def strip
      vars, values, term = @value.strip
      return vars, values, Negate.new( term )
    end

    def demand
      -@value
    end

    def element( i )
      -@value.element( i )
    end

  end

end
