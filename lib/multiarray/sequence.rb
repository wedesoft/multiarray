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
        t = Hornetseye::Sequence typecode, size
        if string.is_a? Malloc
          memory = string
        else
          memory = Malloc.new t.storage_size
          memory.write string
        end
        t.new memory
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

      # Get default value for elements of this type
      #
      # @return [Object] Returns an array of default values.
      #
      # @private
      def default
        Hornetseye::lazy( num_elements ) do |i|
          if element_type.dimension > 0
            element = element_type.default
          else
            element = element_type.new
          end
        end
      end

      # Create (lazy) index array
      #
      # @param [Integer] offset First value of array.
      # @param [Integer] increment Increment for subsequent values.
      #
      # @return [Node] Lazy term generating the array.
      def indgen( offset = 0, increment = 1 )
        Hornetseye::lazy( num_elements ) do |i|
          ( element_type.size * increment * i +
            element_type.indgen( offset, increment ) ).to_type typecode
        end
      end

      # Generate random number array
      #
      # Generate integer or floating point random numbers in the range 0 ... n.
      #
      # @param [Integer,Float] n Upper boundary for random numbers
      #
      # @return [Node] Array with random numbers.
      def random( n = 1 )
        n = typecode.maxint.new n unless n.is_a? Node
        retval = new
        unless compilable? and dimension > 0
          Random.new( retval, n ).demand
        else
          GCCFunction.run Random.new( retval, n )
        end
        retval
      end

      # Construct native array from Ruby array
      #
      # @param [Array<Object>] args Array with Ruby values.
      #
      # @return [Node] Native array with specified values.
      def []( *args )
        retval = new
        recursion = lambda do |element,args|
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

      # Get dimensions of array type
      #
      # @return [Array<Integer>] 
      def shape
        element_type.shape + [ num_elements ]
      end

      # Get width of two-dimensional array type
      #
      # @return [Integer] Width of array.
      def width
        shape[0]
      end

      # Get height of two-dimensional array
      #
      # @return [Integer] Height of array.
      def height
        shape[1]
      end

      # Get size of array type
      #
      # @return [Integer] Size of array.
      def size
        num_elements * element_type.size
      end

      # Get storage size of array type
      #
      # @return [Integer] Storage size of array.
      def storage_size
        num_elements * element_type.storage_size
      end

      # Check whether type denotes an empty array
      #
      # @return [Boolean] Return +true+ for empty array.
      def empty?
        size == 0
      end

      # Get element type of array type
      #
      # @return [Class] Element type of array.
      def typecode
        element_type.typecode
      end

      # Base type of this data type
      #
      # @return [Class] Returns +element_type+.
      #
      # @private
      def basetype
        element_type.basetype
      end

      # Get type of result of delayed operation
      #
      # @return [Class] Type of result.
      #
      # @private
      def array_type
        self
      end

      # Get pointer type of delayed operation
      #
      # @return [Class] Type of result.
      #
      # @private
      def pointer_type
        self
      end

      # Get dimension of type of delayed operation
      #
      # @return [Integer] Number of dimensions.
      def dimension
        element_type.dimension + 1
      end

      # Check arguments for compatible shape
      #
      # The method will throw an exception if one of the arguments has an incompatible
      # shape.
      #
      # @param [Array<Class>] args Arguments to check for compatibility.
      #
      # @return [Object] The return value should be ignored.
      def check_shape( *args )
        _shape = shape
        args.each do |arg|
          _arg_shape = arg.shape
          if _shape.size < _arg_shape.size
            raise "#{arg.inspect} has #{arg.dimension} dimension(s) " +
                  "but should not have more than #{dimension}"
          end
          if ( _shape + _arg_shape ).all? { |s| s.is_a? Integer }
            if _shape.last( _arg_shape.size ) != _arg_shape
              raise "#{arg.inspect} has shape #{arg.shape.inspect} " +
                    "(does not match last value(s) of #{shape.inspect})"
            end
          end
        end
      end

      # Check whether delayed operation will have colour
      #
      # @return [Boolean] Boolean indicating whether the array has elements of type
      #         RGB.
      def rgb?
        element_type.rgb?
      end

      # Get this type
      #
      # @return [Class] Returns +self+.
      #
      # @private
      def identity
        self
      end

      # Get corresponding boolean type
      #
      # @return [Class] Returns type for array of boolean values.
      #
      # @private
      def bool
        Hornetseye::Sequence element_type.bool, num_elements
      end

      # Coerce and convert to boolean type
      #
      # @return [Class] Returns type for array of boolean values.
      #
      # @private
      def coercion_bool( other )
        coercion( other ).bool
      end

      # Get corresponding scalar type
      #
      # @return [Class] Returns type for array of scalars.
      #
      # @private
      def scalar
        Hornetseye::Sequence element_type.scalar, num_elements
      end

      # Get corresponding floating point type
      #
      # @return [Class] Returns type for array of floating point numbers.
      #
      # @private
      def float_scalar
        Hornetseye::Sequence element_type.float_scalar, num_elements
      end

      # Get corresponding maximum integer type
      #
      # @return [Class] Returns type based on maximum integers.
      #
      # @private
      def maxint
        Hornetseye::Sequence element_type.maxint, num_elements
      end

      # Coerce and convert to maximum integer type
      #
      # @return [Class] Returns type based on maximum integers.
      #
      # @private
      def coercion_maxint( other )
        coercion( other ).maxint
      end

      # Get corresponding byte type
      #
      # @return [Class] Returns type based on byte.
      #
      # @private
      def byte
        Hornetseye::Sequence element_type.byte, num_elements
      end

      # Coerce and convert to byte type
      #
      # @return [Class] Returns type based on byte.
      #
      # @private
      def coercion_byte( other )
        coercion( other ).byte
      end

      # Convert to type based on floating point numbers
      #
      # @return [Class] Corresponding type based on floating point numbers.
      #
      # @private
      def float
        Hornetseye::Sequence element_type.float, num_elements
      end

      # Coerce and convert to type based on floating point numbers
      #
      # @return [Class] Corresponding type based on floating point numbers.
      #
      # @private
      def floating( other )
        coercion( other ).float
      end

      # Coerce with two other types
      #
      # @return [Class] Result of coercion.
      #
      # @private
      def cond( a, b )
        t = a.coercion b
        Hornetseye::MultiArray( t.typecode, *shape ).coercion t
      end

      # Replace element type
      #
      # @return [Class] Result of conversion.
      #
      # @private
      def to_type( dest )
        Hornetseye::Sequence element_type.to_type( dest ), num_elements
      end

      # Display this type
      #
      # @return [String] String with description of this type.
      def inspect
        if element_type and num_elements
          if dimension == 1
            retval = "Sequence(#{typecode.inspect},#{num_elements.inspect})"
          else
            retval = "MultiArray(#{typecode.inspect},#{shape.join ','})"
          end
          ( class << self; self; end ).instance_eval do
            define_method( :inspect ) { retval }
          end
          retval
        else
          'MultiArray(?,?)'
        end
      end

      # Compute unique descriptor
      #
      # @return [String] Unique descriptor of this type.
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
        if element_type and num_elements
          if dimension == 1
            "Sequence(#{typecode.descriptor( hash )},#{num_elements.to_s})"
          else
            "MultiArray(#{typecode.descriptor( hash )},#{shape.join ','})"
          end
        else
          'MultiArray(?,?)'
        end
      end

      # Test equality of classes
      #
      # @param [Object] other Object to compare with.
      #
      # @return [Boolean] Boolean indicating whether classes are equal.
      def ==( other )
        other.is_a? Class and other < Sequence_ and
          other.element_type == element_type and
          other.num_elements == num_elements
      end

      # Type coercion for native elements
      #
      # @param [Class] other Other native datatype to coerce with.
      #
      # @return [Class] Result of coercion.
      #
      # @private
      def coercion( other )
        if other < Sequence_
          Hornetseye::Sequence element_type.coercion( other.element_type ),
                               num_elements
        else
          Hornetseye::Sequence element_type.coercion( other ),
                               num_elements
        end
      end

      # Compute balanced type for binary operation
      #
      # @param [Class] other Other type to coerce with.
      #
      # @return [Array<Class>] Result of coercion.
      #
      # @private
      def coerce( other )
        if other < Sequence_
          return other, self
        else
          return Hornetseye::Sequence( other, num_elements ), self
        end
      end

      # Instantiate array of this type
      #
      # @param [Malloc,List] memory Object for storing array elements.
      #
      # @return [Node] The array expression.
      def new( memory = nil )
        MultiArray.new typecode, *( shape + [ :memory => memory ] )
      end

      # Check whether this array expression allows compilation
      #
      # @return [Boolean] Returns +true+ if this expression supports compilation.
      def compilable?
        element_type.compilable?
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
      # @param [Array<Object>] *values Values to find matching native element
      #        type for.
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

      # Perform type alignment
      #
      # Align this type to another. This is used to prefer single-precision
      # floating point in certain cases.
      #
      # @param [Class] context Other type to align with.
      #
      # @private
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

  # Create a class deriving from +Sequence_+
  #
  # Create a class deriving from +Sequence_+. The parameters +element_type+ and
  # +num_elements+ are assigned to the corresponding attribute of the resulting class.
  #
  # @param [Class] element_type The element type of the native array.
  # @param [Integer] num_elements The number of elements.
  #
  # @return [Class] A class deriving from +Sequence_+.
  #
  # @see Sequence_
  # @see Sequence_.element_type
  # @see Sequence_.num_elements
  def Sequence( element_type, num_elements )
    retval = Class.new Sequence_
    retval.element_type = element_type
    retval.num_elements = num_elements
    retval
  end

  module_function :Sequence

end
