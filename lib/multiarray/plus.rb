module Hornetseye

  class Plus < Node

    def initialize( value1, value2 )
      @value1, @value2 = value1, value2
    end

    def inspect
      "(#{@value1.inspect}+#{@value2.inspect})"
    end

    def descriptor( hash )
      "(#{@value1.descriptor( hash )}+#{@value2.descriptor( hash )})"
    end

    def array_type
      @value1.array_type.coercion @value2.array_type
    end

    def subst( hash )
      Plus.new @value1.subst( hash ), @value2.subst( hash )
    end

    def variables
      @value1.variables + @value2.variables
    end

    def strip
      vars1, values1, term1 = @value1.strip
      vars2, values2, term2 = @value2.strip
      return vars1 + vars2, values1 + values2, Plus.new( term1, term2 )
    end

    def demand
      @value1.demand + @value2.demand
    end

    def element( i )
      element1 = @value1.dimension == 0 ? @value1 : @value1.element( i )
      element2 = @value2.dimension == 0 ? @value2 : @value2.element( i )
      element1 + element2
    end

  end

end
