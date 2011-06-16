# multiarray - Lazy multi-dimensional arrays for Ruby
# Copyright (C) 2010, 2011 Jan Wedekind
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

  # Class for representing uniform arrays
  class Sequence

    class << self

      # Allocate new uniform array
      #
      # @param [Class] element_type Type of array elements.
      # @param [Integer] size Number of elements.
      #
      # @return [Node] Returns uninitialised native array.
      def new( element_type, size )
        MultiArray.new element_type, size
      end

      # Import array from string
      #
      # Create an array from raw data provided as a string.
      #
      # @param [Class] typecode Type of the elements in the string.
      # @param [String] string String with raw data.
      # @param [Integer] size Size of array.
      #
      # @return [Node] One-dimensional array with imported data.
      def import( typecode, string, size )
        t = Hornetseye::Sequence typecode
        if string.is_a? Malloc
          memory = string
        else
          memory = Malloc.new t.storage_size(size)
          memory.write string
        end
        t.new size, :memory => memory
      end

      # Convert array to uniform array
      #
      # A native type which fits all elements is determined and used to create
      # a uniform array of those elements.
      #
      # @param [Array<Object>] *args Elements of array.
      #
      # @return [Node] Returns native array with values.
      def []( *args )
        target = Node.fit args
        if target.dimension == 0
          target = Hornetseye::MultiArray target, 1
        elsif target.dimension > 1
          target = Hornetseye::MultiArray OBJECT, 1
        end
        target[*args]
      end

    end

  end

  # Create a class to represent one-dimensional uniform arrays
  #
  # @param [Class] element_type The element type of the native array.
  #
  # @return [Class] A class representing a one-dimensional uniform array.
  def Sequence(element_type)
    Hornetseye::MultiArray element_type, 1
  end

  module_function :Sequence

end
