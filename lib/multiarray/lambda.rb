module Hornetseye

  class Lambda < Node

    def initialize( index, term )
      @index = index
      @term = term
    end

    def inspect
      "Lambda(#{@index.inspect},#{@term.inspect})"
    end

    def descriptor( hash )
      hash = hash.merge @index => ( ( hash.values.max || 0 ) + 1 )
      "Lambda(#{@index.descriptor( hash )},#{@term.descriptor( hash )})"
    end

    def array_type
      Sequence @term.array_type, @index.size.get
    end

    def variables
      @term.variables - @index.variables + @index.meta.variables
    end

    def strip
      vars, values, term = @term.strip
      meta_vars, meta_values, var = @index.strip
      return vars + meta_vars, values + meta_values,
        Lambda.new( var, term.subst( @index => var ) )
    end

    def subst( hash )
      subst_var = @index.subst hash
      Lambda.new subst_var, @term.subst( @index => subst_var ).subst( hash )
    end

    def store( value )
      shape.last.times do |i|
        node = value.dimension == 0 ? value : value.element( INT.new( i ) )
        element( INT.new( i ) ).store node
      end
      value
    end

    def lookup( value, stride )
      if value.is_a? Variable
        Lookup.new self, value, stride
      else
        Lambda.new @index, @term.lookup( value, stride )
      end
    end

    def element( i )
      i = Node.match( i ).new i unless i.is_a? Node
      i.size[] ||= @index.size[] if i.is_a? Variable
      @term.subst @index => i
    end

  end

end
