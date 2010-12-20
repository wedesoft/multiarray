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

  # This class provides methods for initialising multi-dimensional arrays
  class MultiArray

    class << self

      # Create new multi-dimensional array
      #
      # @param [Class] typecode The type of elements
      # @param [Array<Integer>] *shape The shape of the multi-dimensional array.
      #
      # @return [Node] Returns uninitialised native array.
      def new( typecode, *shape )
        options = shape.last.is_a?( Hash ) ? shape.pop : {}
        count = options[ :count ] || 1
        if shape.empty?
          memory = options[ :memory ] ||
                   typecode.memory_type.new( typecode.storage_size * count )
          Hornetseye::Pointer( typecode ).new memory
        else
          size = shape.pop
          stride = shape.inject( 1 ) { |a,b| a * b }
          Hornetseye::lazy( size ) do |index|
            pointer = new typecode, *( shape + [ :count => count * size,
                                                 :memory => options[ :memory ] ] )
            Lookup.new pointer, index, INT.new( stride )
          end
        end
      end

      # Import array from string
      #
      # Create an array from raw data provided as a string.
      #
      # @param [Class] typecode Type of the elements in the string.
      # @param [String] string String with raw data.
      # @param [Array<Integer>] shape Array with dimensions of array.
      #
      # @return [Node] Multi-dimensional array with imported data.
      def import( typecode, string, *shape )
        t = Hornetseye::MultiArray typecode, *shape
        if string.is_a? Malloc
          memory = string
        else
          memory = Malloc.new t.storage_size
          memory.write string
        end
        t.new memory
      end

      # Convert Ruby array to uniform multi-dimensional array
      #
      # Type matching is used to find a common element type. Furthermore the required
      # shape of the array is determined. Finally the elements are coopied to the
      # resulting array.
      #
      # @param [Array<Object>] *args
      #
      # @return [Node] Uniform multi-dimensional array.
      def []( *args )
        target = Node.fit args
        target[ *args ]
      end

    end

  end

  # Create multi-dimensional array type
  #
  # @param [Class] element_type Type of elements.
  # @param [Array<Integer>] *shape Shape of array type.
  #
  # @return [Class] The array type.
  def MultiArray( element_type, *shape )
    if shape.empty?
      element_type
    else
      Hornetseye::Sequence MultiArray( element_type, *shape[ 0 ... -1 ] ),
                           shape.last
    end
  end

  module_function :MultiArray

end
