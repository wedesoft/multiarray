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

  # Class for representing uniform arrays
  class Sequence

    class << self

      # Allocate new uniform array
      #
      # @param [Class] typecode Type of array elements.
      # @param [Integer] size Number of elements.
      #
      # @return [Node] Returns uninitialised native array.
      def new( typecode, size )
        MultiArray.new typecode, size
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
          target = Hornetseye::Sequence target, 0
        elsif target.dimension > 1
          target = Hornetseye::Sequence OBJECT, args.size
        end
        target[ *args ]
      end

    end

  end

  # Class for representing n-dimensional native arrays
  class Sequence_

    class << self

      # Type of array elements
      #
      # @return [Class] element_type Type of array elements.
      attr_accessor :element_type

      # Number of array elements
      #
      # @return [Integer] num_elements Number of elements.
      attr_accessor :num_elements

      def default
        Hornetseye::lazy( num_elements ) do |i|
          if element_type.dimension > 0
            element = element_type.default
          else
            element = element_type.new
          end
        end
      end

      def indgen( offset = 0, increment = 1 )
        Hornetseye::lazy( num_elements ) do |i|
          element_type.size * increment * i +
            element_type.indgen( offset, increment )
        end
      end

      def []( *args )
        retval = new
        recursion = proc do |element,args|
          if element.dimension > 0
            args.each_with_index do |arg,i|
              recursion.call element.element( i ), arg
            end
          else
            element[] = args
          end
        end
        recursion.call retval, args
        retval
      end

      def shape
        element_type.shape + [ num_elements ]
      end

      def size
        num_elements * element_type.size
      end

      def empty?
        size == 0
      end

      def typecode
        element_type.typecode
      end

      def basetype
        element_type.basetype
      end

      def array_type
        self
      end

      def pointer_type
        self
      end

      def dimension
        element_type.dimension + 1
      end

      def contiguous
        self
      end

      def bool
        Hornetseye::Sequence element_type.bool, num_elements
      end

      def bool_binary( other )
        coercion( other ).bool
      end

      def maxint
        Hornetseye::Sequence element_type.maxint, num_elements
      end

      def largeint( other )
        coercion( other ).maxint
      end

      def byte
        Hornetseye::Sequence element_type.byte, num_elements
      end

      def byteval( other )
        coercion( other ).byte
      end

      def float
        Hornetseye::Sequence element_type.float, num_elements
      end

      def floating( other )
        coercion( other ).float
      end

      def inspect
        if dimension == 1
          "Sequence(#{typecode.inspect},#{num_elements.inspect})"
        else
          "MultiArray(#{typecode.inspect},#{shape.join ','})"
        end
      end

      def to_s
        descriptor( {} )
      end

      # Get unique descriptor of this class
      #
      # @param [Hash] hash Labels for any variables.
      #
      # @return [String] Descriptor of this class.
      #
      # @private
      def descriptor( hash )
        if dimension == 1
          "Sequence(#{typecode.descriptor( hash )},#{num_elements.to_s})"
        else
          "MultiArray(#{typecode.descriptor( hash )},#{shape.join ','})"
        end
      end

      def ==( other )
        other.is_a? Class and other < Sequence_ and
          other.element_type == element_type and
          other.num_elements == num_elements
      end

      def coercion( other )
        if other < Sequence_
          Hornetseye::Sequence element_type.coercion( other.element_type ),
                               num_elements
        else
          Hornetseye::Sequence element_type.coercion( other ),
                               num_elements
        end
      end

      def coerce( other )
        if other < Sequence_
          return other, self
        else
          return Hornetseye::Sequence( other, num_elements ), self
        end
      end

      def new
        MultiArray.new typecode, *shape
      end

    end

    # Namespace containing method for matching elements of type Sequence_
    #
    # @see Sequence_
    #
    # @private
    module Match

      # Method for matching elements of type Sequence_
      #
      # 'param [Array<Object>] *values Values to find matching native element
      # type for.
      #
      # @return [Class] Native type fitting all values.
      #
      # @see Sequence_
      #
      # @private
      def fit( *values )
        n = values.inject 0 do |size,value|
          value.is_a?( Array ) ? [ size, value.size ].max : size
        end
        if n > 0
          elements = values.inject [] do |flat,value|
            flat + ( value.is_a?( Array ) ? value : [ value ] )
          end
          Hornetseye::Sequence fit( *elements ), n
        else
          super *values
        end
      end

      def align( context )
        if self < Sequence_
          Hornetseye::Sequence element_type.align( context ), num_elements
        else
          super context
        end
      end

    end

    Node.extend Match

  end

  def Sequence( element_type, num_elements )
    retval = Class.new Sequence_
    retval.element_type = element_type
    retval.num_elements = num_elements
    retval
  end

  module_function :Sequence

end
