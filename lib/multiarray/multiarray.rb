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
      # @param [Class] element_type The type of the elements.
      # @param [Array<Integer>] *array_shape The shape of the multi-dimensional array.
      #
      # @return [Node] Returns uninitialised native array.
      def new( element_type, *array_shape )
        typecode = element_type.typecode
        shape = element_type.shape + array_shape
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
      # @param [Array<Object>] *args The array elements.
      #
      # @return [Node] Uniform multi-dimensional array.
      def []( *args )
        target = Node.fit args
        target[ *args ]
      end

      # Compute Laplacian of Gaussian filter
      #
      # @param [Float] sigma Spread of filter.
      # @param [Integer] size Size of filter (*e.g.* 9 for 9x9 filter)
      #
      # @return[Node] The filter.
      def laplacian_of_gaussian( sigma = 1.4, size = 9 )
        def erf( x, sigma )
          0.5 * Math.erf( x / ( Math.sqrt( 2.0 ) * sigma.abs ) )
        end
        def gauss_gradient( x, sigma )
          -x / ( Math.sqrt( 2.0 * Math::PI * sigma.abs**5 ) ) *
            Math.exp( -x**2 / ( 2.0 * sigma**2 ) )
        end
        retval = new DFLOAT, size, size
        sum = 0
        for y in 0 .. size - 1
          y0 = y - 0.5 * size
          y1 = y0 + 1
          y_grad_diff = gauss_gradient( y1, sigma ) - gauss_gradient( y0, sigma )
          y_erf_diff = erf( y1, sigma ) - erf( y0, sigma )
          for x in 0..size-1
            x0 = x - 0.5 * size
            x1 = x0 + 1
            x_grad_diff = gauss_gradient( x1, sigma ) - gauss_gradient( x0, sigma )
            x_erf_diff = erf( x1, sigma ) - erf( x0, sigma )
            retval[ y, x ] = y_grad_diff * x_erf_diff + y_erf_diff * x_grad_diff
          end
        end
        retval
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
