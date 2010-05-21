module Hornetseye

  class Inject < Node

    def initialize( value, index, initial, block, var1, var2 )
      @value, @index, @initial, @block, @var1, @var2 =
        value, index, initial, block, var1, var2
    end

    def descriptor( hash )
      hash = hash.merge @index => ( ( hash.values.max || 0 ) + 1 )
      hash = hash.merge @var1 => ( ( hash.values.max || 0 ) + 1 )
      hash = hash.merge @var2 => ( ( hash.values.max || 0 ) + 1 )
      "Inject(#{@value.descriptor( hash )},#{@initial ? @initial.descriptor( hash ) : 'nil'},#{@index.descriptor( hash )},#{@block.descriptor( hash )})"
    end

    def array_type
      @block.array_type
    end

    def demand
      if @initial
        retval = @initial.demand
        @index.size.get.times do |i|
          sub = @value.subst( @index => INT.new( i ) ).demand
          retval.store @block.subst( @var1 => retval,
                                     @var2 => sub ).demand
        end
      else
        retval = @value.subst( @index => INT.new( 0 ) ).demand
        ( @index.size - 1 ).get.times do |i|
          sub = @value.subst( @index => INT.new( i ) + 1 ).demand
          retval.store @block.subst( @var1 => retval,
                                     @var2 => sub ).demand
        end
      end
      retval
    end

    def variables
      initial_variables = @initial ? @initial.variables : Set[]
      ( @value.variables + initial_variables ) - @index.variables
    end

    def strip
      vars1, values1, term1 = @value.strip
      if @initial
        vars2, values2, term2 = @initial.strip
      else
        vars2, values2 = [], [], nil
      end
      vars3, values3, term3 = @block.strip
      meta_vars, meta_values, var = @index.strip
      return vars1 + vars2 + vars3 + meta_vars,
        values1 + values2 + values3 + meta_values,
        Inject.new( term1.subst( @index => var ),
                    var, term2, term3, @var1, @var2 )
    end
 
    def subst( hash )
      subst_var = @index.subst hash
      value = @value.subst( @index => subst_var ).subst hash
      initial = @initial ? @initial.subst( hash ) : nil
      block = @block.subst hash
      Inject.new value, subst_var, initial, block, @var1, @var2
    end

  end

end
