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
    # @param [Node] dest Target array to write histogram to.
    # @param [Node] source Expression to compute histogram of.
    # @param [Integer] n Number of dimensions of lookup.
    #
    # @private
    def initialize( source, table, n = nil )
      @source, @table = source, table
      @n = n || @source.shape.first
    end

    # Get unique descriptor of this object
    #
    # @param [Hash] hash Labels for any variables.
    #
    # @return [String] Descriptor of this object,
    #
    # @private
    def descriptor( hash )
      "Lut(#{@source.descriptor( hash )},#{@table.descriptor( hash )},#{@n})"
    end

    # Get type of result of delayed operation
    #
    # @return [Class] Type of result.
    #
    # @private
    def array_type
      shape = @table.shape.first( @table.dimension - @n ) + @source.shape[ 1 .. -1 ]
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
      @source.lut @table, :n => @n, :safe => false
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
      self.class.new @source.subst( hash ), @table.subst( hash ), @n
    end

    # Get variables contained in this term
    #
    # @return [Set] Returns list of variables.
    #
    # @private
    def variables
      @source.variables + @table.variables
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
      vars1, values1, term1 = @source.strip
      vars2, values2, term2 = @table.strip
      return vars1 + vars2, values1 + values2, self.class.new( term1, term2, @n )
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
      self.class.new @source.skip( index, start ), @table.skip( index, start ), @n
    end

    # Get element of unary operation
    #
    # @param [Integer,Node] i Index of desired element.
    #
    # @return [Node,Object] Element of unary operation.
    #
    # @private
    def element( i )
      source, table = @source, @table
      if source.dimension > 1
        source = source.element i
        self.class.new source, table, @n
      elsif table.dimension > @n
        self.class.new source, table.unroll( @n ).element( i ).roll( @n ), @n
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
      self.class.new @source, @table.decompose( i ), @n
    end

    # Check whether this term is compilable
    #
    # @return [Boolean] Returns whether this term is compilable.
    #
    # @private
    def compilable?
      @source.compilable? and @table.compilable?
    end

  end

end

