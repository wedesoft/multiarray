# multiarray - Lazy multi-dimensional arrays for Ruby
# Copyright (C) 2010 Jan Wedekind
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Namespace of Hornetseye computer vision library
module Hornetseye

  class Diagonal < Node

    def initialize( value, index0, index1, index2, initial, block, var1, var2 )
      @value, @index0, @index1, @index2, @initial, @block, @var1, @var2 =
        value, index0, index1, index2, initial, block, var1, var2
    end

    def descriptor( hash )
      hash = hash.merge @index0 => ( ( hash.values.max || 0 ) + 1 )
      hash = hash.merge @index1 => ( ( hash.values.max || 0 ) + 1 )
      hash = hash.merge @index2 => ( ( hash.values.max || 0 ) + 1 )
      hash = hash.merge @var1 => ( ( hash.values.max || 0 ) + 1 )
      hash = hash.merge @var2 => ( ( hash.values.max || 0 ) + 1 )
      "Diagonal(#{@value.descriptor( hash )},#{@initial ? @initial.descriptor( hash ) : 'nil'},#{@block.descriptor( hash )})"
    end

    def array_type
      Hornetseye::MultiArray @block.typecode, *@value.shape
    end

    def demand
      retval = @initial
      offset = @index2.size.get / 2
      @index2.size.get.times do |j|
        k = j - offset
        i = @index0.get - k
        if i >= 0 and i < @index1.size.get
          sub = @value.subst( @index1 => INT.new( i ),
                             @index2 => INT.new( j ) ).demand
          retval = retval ? @block.subst( @var1 => retval,
                                         @var2 => sub ).demand :
            sub
        end
      end
      retval
    end

    def element( i )
      Diagonal.new @value.element( i ), @index0, @index1, @index2, @initial,
        @block, @var1, @var2
    end

    def variables
      initial_variables = @initial ? @initial.variables : Set[]
      @value.variables + initial_variables - 
        ( @index1.variables + @index2.variables )
    end

    def variables
      initial_variables = @initial ? @initial.variables : Set[]
      @value.variables + initial_variables - 
        ( @index1.variables + @index2.variables )
    end

    def strip
      vars1, values1, term1 = @value.strip
      meta_vars1, meta_values1, var1 = @index1.strip
      meta_vars2, meta_values2, var2 = @index2.strip
      if @initial
        vars2, values2, term2 = @initial.strip
      else
        vars2, values2, term2 = [], [], nil
      end
      vars3, values3, term3 = @block.strip
      return vars1 + meta_vars1 + meta_vars2 + vars2 + vars3,
        values1 + meta_values1 + meta_values2 + values2 + values3,
        Diagonal.new( term1.subst( @index1 => var1, @index2 => var2 ),
                      @index0, var1, var2, term2, term3, @var1, @var2 )
    end

    def subst( hash )
      subst_var0 = @index0.subst hash
      subst_var1 = @index1.subst hash
      subst_var2 = @index2.subst hash
      value = @value.subst( @index0 => subst_var0, @index1 => subst_var1,
                            @index2 => subst_var2 ).subst hash
      initial = @intial ? @initial.subst( hash ) : nil
      block = @block.subst hash
      Diagonal.new value, subst_var0, subst_var1, subst_var2, initial,
        block, @var1, @var2
    end

  end

end
