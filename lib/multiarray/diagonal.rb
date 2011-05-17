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

  # Class for representing diagonal injections
  class Diagonal < Node

    class << self

      # Check whether objects of this class are finalised computations
      #
      # @return [Boolean] Returns +false+.
      #
      # @private
      def finalised?
        false
      end

    end

    # Constructor
    #
    # @param [Node] value Initial value of injection.
    # @param [Node] index0 Index to select starting point of injection.
    # @param [Node] index1 Index to diagonally iterate over +value+.
    # @param [Node] index2 Index to diagonally iterate over +value+.
    # @param [Node,NilClass] initial Initial value for injection.
    # @param [Node] block Expression with body of injection.
    # @param [Variable] var1 Variable for performing substitutions on body of
    #        injection.
    # @param [Variable] var2 Variable for performing substitutions on body of
    #        injection.
    #
    # @private
    def initialize( value, index0, index1, index2, initial, block, var1,
                    var2 )
      @value, @index0, @index1, @index2, @initial, @block, @var1, @var2 =
        value, index0, index1, index2, initial, block, var1, var2
    end

    # Get unique descriptor of this object
    #
    # @param [Hash] hash Labels for any variables.
    #
    # @return [String] Descriptor of this object,
    #
    # @private
    def descriptor( hash )
      hash = hash.merge @index1 => ( ( hash.values.max || 0 ) + 1 )
      hash = hash.merge @index2 => ( ( hash.values.max || 0 ) + 1 )
      hash = hash.merge @var1 => ( ( hash.values.max || 0 ) + 1 )
      hash = hash.merge @var2 => ( ( hash.values.max || 0 ) + 1 )
      "Diagonal(#{@value.descriptor( hash )},#{@index0.descriptor( hash )}," +
        "#{@index1.descriptor( hash )},#{@index2.descriptor( hash )}," +
        "#{@initial ? @initial.descriptor( hash ) : 'nil'}," +
        "#{@block.descriptor( hash )})"
    end

    def typecode
      @block.typecode
    end

    def shape
      @value.shape
    end

    # Reevaluate computation
    #
    # @return [Node,Object] Result of computation
    #
    # @see #force
    #
    # @private
    def demand
      s1 = @index2.size / 2
      j0 = INT.new( 0 ).major( @index0 + s1 + 1 - @index1.size )
      if @initial
        retval = @initial.simplify
      else
        j = j0.get
        i = @index0.get + s1.get - j
        retval = @value.subst( @index1 => INT.new( i ),
                               @index2 => INT.new( j ) ).simplify
        j0 = ( j0 + 1 ).simplify
      end
      j0.upto( ( @index2.size - 1 ).minor( @index0 + s1 ) ) do |j|
        i = @index0.get + s1.get - j
        sub = @value.subst @index1 => INT.new( i ), @index2 => INT.new( j )
        retval.assign @block.subst( @var1 => retval, @var2 => sub )
      end
      retval
    end

    # Get element of diagonal injection
    #
    # @param [Integer,Node] i Index of desired element.
    #
    # @return [Node,Object] Element of diagonal injection.
    #
    # @private
    def element( i )
      Diagonal.new @value.element( i ), @index0, @index1, @index2, @initial,
        @block, @var1, @var2
    end

    # Get variables contained in this term
    #
    # @return [Set] Returns list of variables.
    #
    # @private
    def variables
      initial_variables = @initial ? @initial.variables : Set[]
      @value.variables + initial_variables + @index0.variables - 
        ( @index1.variables + @index2.variables )
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
      meta_vars1, meta_values1, var1 = @index1.strip
      meta_vars2, meta_values2, var2 = @index2.strip
      vars1, values1, term1 =
        @value.subst( @index1 => var1, @index2 => var2 ).strip
      if @initial
        vars2, values2, term2 = @initial.strip
      else
        vars2, values2, term2 = [], [], nil
      end
      vars3, values3, term3 = @block.strip
      return vars1 + meta_vars1 + meta_vars2 + vars2 + vars3,
        values1 + meta_values1 + meta_values2 + values2 + values3,
        Diagonal.new( term1, @index0, var1, var2, term2, term3, @var1, @var2 )
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
      subst_var0 = @index0.subst hash
      subst_var1 = @index1.subst hash
      subst_var2 = @index2.subst hash
      value = @value.subst( @index0 => subst_var0, @index1 => subst_var1,
                            @index2 => subst_var2 ).subst hash
      initial = @initial ? @initial.subst( hash ) : nil
      block = @block.subst hash
      Diagonal.new value, subst_var0, subst_var1, subst_var2, initial,
        block, @var1, @var2
    end

    # Check whether this term is compilable
    #
    # @return [Boolean] Returns whether this term is compilable.
    #
    # @private
    def compilable?
      initial_compilable = @initial ? @initial.compilable? : true
      @value.compilable? and initial_compilable and @block.compilable?
    end

  end

end

