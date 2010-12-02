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

  # Class for representing lookup operations
  class Lut < Node

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
    # @overload initialize( *sources, table )
    #   @param [Array<Node>] sources Arrays with elements for lookup
    #   @param [Node] table Lookup table
    #
    # @private
    def initialize( *args )
      @sources, @table = args[ 0 ... -1 ], args.last
    end

    # Get unique descriptor of this object
    #
    # @param [Hash] hash Labels for any variables.
    #
    # @return [String] Descriptor of this object,
    #
    # @private
    def descriptor( hash )
      "Lut(#{@sources.collect { |source| source.descriptor( hash ) }.join ','}," +
        "#{@table.descriptor( hash )})"
    end

    # Get type of result of delayed operation
    #
    # @return [Class] Type of result.
    #
    # @private
    def array_type
      source_type = @sources.collect { |source| source.array_type }.
        inject { |a,b| a.coercion b }
      shape = @table.shape.first( @table.dimension - @sources.size ) +
        source_type.shape
      retval = Hornetseye::MultiArray @table.typecode, *shape
      ( class << self; self; end ).instance_eval do
        define_method( :array_type ) { retval }
      end
      retval
    end

    # Reevaluate computation
    #
    # @return [Node,Object] Result of computation
    #
    # @see #force
    #
    # @private
    def demand
      @sources.lut @table, :safe => false
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
      self.class.new *( @sources.collect { |source| source.subst hash } +
                        [ @table.subst( hash ) ] )
    end

    # Get variables contained in this term
    #
    # @return [Set] Returns list of variables.
    #
    # @private
    def variables
      @sources.inject( @table.variables ) { |a,b| a + b.variables }
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
      stripped = ( @sources + [ @table ] ).collect { |source| source.strip }
      return stripped.inject( [] ) { |vars,elem| vars + elem[ 0 ] },
           stripped.inject( [] ) { |values,elem| values + elem[ 1 ] },
           self.class.new( *stripped.collect { |elem| elem[ 2 ] } )
    end

    # Skip elements of an array
    #
    # @param [Variable] index Variable identifying index of array.
    # @param [Node] start Wrapped integer with number of elements to skip.
    #
    # @return [Node] Returns element-wise operation with elements skipped on each
    #         operand.
    #
    # @private
    def skip( index, start )
      self.class.new *( @sources.skip( index, start ) +
                        [ @table.skip( index, start ) ] )
    end

    # Get element of unary operation
    #
    # @param [Integer,Node] i Index of desired element.
    #
    # @return [Node,Object] Element of unary operation.
    #
    # @private
    def element( i )
      sources, table = @sources, @table
      if sources.any? { |source| source.dimension > 0 }
        sources = sources.
          collect { |source| source.dimension > 0 ? source.element( i ) : source }
        self.class.new *( sources + [ table ] )
      elsif table.dimension > sources.size
        n = sources.size
        self.class.new *( sources + [ table.unroll( n ).element( i ).roll( n ) ] )
      else
        super i
      end
    end

    # Extract array view with part of array
    #
    # @param [Integer,Node] start Number of elements to skip.
    # @param [Integer,Node] length Size of array view.
    #
    # @return [Node] Array view with the specified elements.
    #
    # @private
    def slice( start, length )
      source, table = @source, @table
      if source.dimension > 1
        source = source.slice( start, length ).roll
        self.class.new( source, table, @n ).unroll
      elsif table.dimension > @n
        self.class.new( source,
                        table.unroll( @n ).slice( start, length ).roll( @n + 1 ),
                        @n ).unroll
      else
        super i
      end
    end

    # Decompose composite elements
    #
    # This method decomposes composite elements into array.
    #
    # @return [Node] Result of decomposition.
    def decompose( i )
      self.class.new *( @sources + [ @table.decompose( i ) ] )
    end

    # Check whether this term is compilable
    #
    # @return [Boolean] Returns whether this term is compilable.
    #
    # @private
    def compilable?
      @sources.all? { |source| source.compilable? } and @table.compilable?
    end

  end

end

