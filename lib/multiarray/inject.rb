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

  class Inject < Node

    def initialize( value, index, initial, block, var1, var2 )
      @value, @index, @initial, @block, @var1, @var2 =
        value, index, initial, block, var1, var2
    end

    # Get unique descriptor of this object
    #
    # @param [Hash] hash Labels for any variables.
    #
    # @return [String] Descriptor of this object,
    #
    # @private
    def descriptor( hash )
      hash = hash.merge @index => ( ( hash.values.max || 0 ) + 1 )
      hash = hash.merge @var1 => ( ( hash.values.max || 0 ) + 1 )
      hash = hash.merge @var2 => ( ( hash.values.max || 0 ) + 1 )
      "Inject(#{@value.descriptor( hash )},#{@initial ? @initial.descriptor( hash ) : 'nil'},#{@index.descriptor( hash )},#{@block.descriptor( hash )})"
    end

    def array_type
      @block.array_type
    end

    # Reevaluate computation
    #
    # @return [Node,Object] Result of computation
    #
    # @see #force
    #
    # @private
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
# raise 'Doo!' if retval.inspect == '( v03 ) == ( v04 )'
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

    # Strip of all values
    #
    # Split up into variables, values, and a term where all values have been
    # replaced with variables.
    #
    # @return [Array<Array,Node>] Returns an array of variables, an array of
    # values, and the term based on variables.
    #
    # @private
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
