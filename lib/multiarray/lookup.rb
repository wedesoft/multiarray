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

  # Class for lazy array lookup
  class Lookup < Node

    # Create array lookup
    #
    # @param [Node] p Object supporting lookup.
    # @param [Variable] index The array index.
    # @param [Node] stride The array stride.
    def initialize( p, index, stride )
      @p, @index, @stride = p, index, stride
    end

    def memory
      #if array_type.storage_size != @stride.get * typecode.storage_size
      #  raise 'Memory is not contiguous'
      #end
      @p.memory
    end

    # Get unique descriptor of this object
    #
    # @param [Hash] hash Labels for any variables.
    #
    # @return [String] Descriptor of this object,
    #
    # @private
    def descriptor( hash )
      "Lookup(#{@p.descriptor( hash )},#{@index.descriptor( hash )}," +
        "#{@stride.descriptor( hash )})"
    end

    # Get type of result of delayed operation
    #
    # @return [Class] Type of result.
    #
    # @private
    def array_type
      retval = @p.array_type
      ( class << self; self; end ).instance_eval do
        define_method( :array_type ) { retval }
      end
      retval
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
      @p.subst( hash ).lookup @index.subst( hash ), @stride.subst( hash )
    end

    # Get variables contained in this object
    #
    # @return [Set] Returns +Set[ self ]+.
    #
    # @private
    def variables
      @p.variables + @index.variables + @stride.variables
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
      vars1, values1, term1 = @p.strip
      vars2, values2, term2 = @stride.strip
      return vars1 + vars2, values1 + values2,
        Lookup.new( term1, @index, term2 )
    end

    # Lookup element of an array
    #
    # @param [Node] value Index of element.
    # @param [Node] stride Stride for iterating over elements.
    #
    # @private
    def lookup( value, stride )
      if value.is_a? Variable
        Lookup.new self, value, stride
      else
        Lookup.new @p.lookup( value, stride ), @index, @stride
      end
    end

    # Skip elements of an array
    #
    # @param [Variable] index Variable identifying index of array.
    # @param [Node] start Wrapped integer with number of elements to skip.
    #
    # @return [Node] Lookup object with elements skipped.
    #
    # @private
    def skip( index, start )
      if @index == index
        Lookup.new @p.lookup( start, @stride ), @index, @stride
      else
        Lookup.new @p.skip( index, start ), @index, @stride
      end
    end

    # Get element if lookup term
    #
    # @param [Integer,Node] i Index of desired element.
    #
    # @return [Node,Object] Element of lookup term.
    #
    # @private
    def element( i )
      Lookup.new @p.element( i ), @index, @stride
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
      Lookup.new @p.slice( start, length ), @index, @stride
    end

    # Decompose composite elements
    #
    # This method decomposes composite elements into array.
    #
    # @return [Node] Result of decomposition.
    def decompose( i )
      if typecode < Composite
        Lookup.new @p.decompose( i ), @index, @stride * typecode.num_elements
      else
        Lookup.new @p.decompose( i ), @index, @stride
      end
    end

  end

end
