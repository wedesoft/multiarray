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
      @value.array_type
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
        retval = @initial.simplify # !!!
        @index.size.get.times do |i|
          sub = @value.subst( @index => INT.new( i ) ).simplify # !!!
          retval.store @block.subst( @var1 => retval,
                                     @var2 => sub ).simplify
        end
      else
        retval = @value.subst( @index => INT.new( 0 ) ).simplify # !!!
        ( @index.size - 1 ).get.times do |i|
          sub = @value.subst( @index => INT.new( i ) + 1 ).simplify # !!!
          retval.store @block.subst( @var1 => retval,
                                     @var2 => sub ).simplify
        end
      end
      retval
    end

    # Get element of injection
    #
    # @param [Integer,Node] i Index of desired element.
    #
    # @return [Node,Object] Element of injection.
    def element( i )
      Inject.new @value.element( i ), @index, @initial, @block, @var1, @var2
    end

    # Get variables contained in this term
    #
    # @return [Set] Returns set of variables.
    #
    # @private
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
      meta_vars, meta_values, var = @index.strip
      vars1, values1, term1 = @value.subst( @index => var ).strip
      if @initial
        vars2, values2, term2 = @initial.strip
      else
        vars2, values2 = [], [], nil
      end
      vars3, values3, term3 = @block.strip
      return vars1 + vars2 + vars3 + meta_vars,
        values1 + values2 + values3 + meta_values,
        Inject.new( term1, var, term2, term3, @var1, @var2 )
    end
 
    # Substitute variables
    #
    # Substitute the variables with the values given in the hash.
    #
    # @param [Hash] hash Substitutions to apply.
    #
    # @return [Node] Term with substitutions applied.
    #
    # @private
    def subst( hash )
      subst_var = @index.subst hash
      value = @value.subst( @index => subst_var ).subst hash
      initial = @initial ? @initial.subst( hash ) : nil
      block = @block.subst hash
      Inject.new value, subst_var, initial, block, @var1, @var2
    end

    # Check whether this term is compilable
    #
    # @return [FalseClass,TrueClass] Returns whether this term is compilable.
    #
    # @private
    def compilable?
      initial_compilable = @initial ? @initial.compilable? : true
      @value.compilable? and initial_compilable and @block.compilable?
    end

  end

end
