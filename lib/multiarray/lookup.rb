module Hornetseye

  class Lookup < Node
    def initialize( p, index, stride )
      @p, @index, @stride = p, index, stride
    end
    def inspect
      "Lookup(#{@p.inspect},#{@index.inspect},#{@stride.inspect})"
    end
    def descriptor( hash )
      "Lookup(#{@p.descriptor( hash )},#{@index.descriptor( hash )},#{@stride.descriptor( hash )})"
    end
    def array_type
      @p.array_type
    end
    def subst( hash )
      @p.subst( hash ).lookup @index.subst( hash ), @stride.subst( hash )
    end
    def variables
      @p.variables + @index.variables + @stride.variables
    end
    def strip
      vars1, values1, term1 = @p.strip
      vars2, values2, term2 = @stride.strip
      return vars1 + vars2, values1 + values2,
        Lookup.new( term1, @index, term2 )
    end
    def lookup( value, stride )
      if value.is_a? Variable
        Lookup.new self, value, stride
      else
        Lookup.new @p.lookup( value, stride ), @index, @stride
      end
    end
    def element( i )
      Lookup.new @p.element( i ), @index, @stride
    end
  end

end
