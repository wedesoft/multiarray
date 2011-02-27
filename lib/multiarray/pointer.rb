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

  # Class for representing native pointer types
  class Pointer_ < Node

    class << self

      # Target type of pointer
      #
      # @return [Node] Type of object the pointer is pointing at.
      attr_accessor :target

      # Construct new object from arguments
      #
      # @param [Array<Object>] *args Arguments for constructor.
      #
      # @return [Element] New object of this type.
      #
      # @private
      def construct( *args )
        new *args
      end

      # Display string with information about this class
      #
      # @return [String] String with information about this class (e.g. '*(UBYTE)').
      def inspect
        "*(#{target.inspect})"
      end

      # Get unique descriptor of this class
      #
      # @param [Hash] hash Labels for any variables.
      #
      # @return [String] Descriptor of this class.
      #
      # @private
      def descriptor( hash )
        inspect
      end

      # Get default value for elements of this type
      #
      # @return [Memory,List] Memory for storing one object of type +target+.
      def default
        target.memory_type.new target.storage_size
      end

      # Test equality of classes
      #
      # @param [Object] other Object to compare with.
      #
      # @return [Boolean] Boolean indicating whether classes are equal.
      def ==( other )
        other.is_a? Class and other < Pointer_ and
          target == other.target
      end

      # Compute hash value for this class
      #
      # @return [Fixnum] Hash value
      #
      # @private
      def hash
        [ :Pointer_, target ].hash
      end

      # Equality for hash operations
      #
      # @param [Object] other Object to compare with.
      #
      # @return [Boolean] Returns +true+ if objects are equal.
      #
      # @private
      def eql?
        self == other
      end

      # Get element type
      #
      # @return [Class] Returns the corresponding element type.
      def typecode
        target
      end

      # Base type of this data type
      #
      # @return [Class] Returns +element_type+.
      #
      # @private
      def basetype
        target.basetype
      end

      # Get type of result of delayed operation
      #
      # @return [Class] Type of result.
      #
      # @private
      def array_type
        target
      end

      # Get corresponding pointer type
      #
      # @return [Class] Returns +self+.
      def pointer_type
        self
      end

      # Check whether objects of this class are finalised computations
      #
      # @return [Boolean] Returns +false+.
      #
      # @private
      def finalised?
        false
      end

    end

    # Constructor for pointer object
    #
    # @param [Malloc,List] value Initial value for pointer object.
    def initialize( value = self.class.default )
      @value = value
    end

    # Get access to storage object
    #
    # @return [Malloc,List] The object used to store the data.
    def memory
      @value
    end

    # Get strides of array
    #
    # @return [Array<Integer>,NilClass] Array strides of this type.
    #
    # @private
    def strides
      []
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
      variable = Variable.new self.class
      return [ variable ], [ self ], variable
    end

    # Get unique descriptor of this object
    #
    # @param [Hash] hash Labels for any variables.
    #
    # @return [String] Descriptor of this object,
    #
    # @private
    def descriptor( hash )
      "#{self.class.to_s}(#{@value.to_s})"
    end

    # Store a value in this native element
    #
    # @param [Object] value New value for native element.
    #
    # @return [Object] Returns +value+.
    #
    # @private
    def assign( value )
      if @value.respond_to? :assign
        @value.assign value.simplify.get
      else
        @value = value.simplify.get
      end
      value
    end

    # Store new value in this pointer
    #
    # @param [Object] value New value for this pointer object.
    #
    # @return [Object] Returns +value+.
    #
    # @private
    def store( value )
      result = value.simplify
      self.class.target.new( result.get ).write @value
      result
    end

    # Reevaluate computation
    #
    # @return [Node,Object] Result of computation
    #
    # @see #force
    #
    # @private
    def demand
      self.class.target.fetch( @value ).simplify
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
        self.class.new @value + ( stride.get *
                                  self.class.target.storage_size ) * value.get
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
      self
    end

    # Decompose composite elements
    #
    # This method decomposes composite elements into array.
    #
    # @return [Node] Result of decomposition.
    def decompose( i )
      if self.class.target < Composite
        pointer = Hornetseye::Pointer( self.class.target.element_type ).new @value
        pointer.lookup INT.new( i ), INT.new( 1 )
      else
        super
      end
    end

    # Get array with components of this value
    #
    # @return [Array<Object>] Get array with value of this object as single element.
    #
    # @private
    def values
      [ @value ]
    end

  end

  # Create a class deriving from +Pointer_+
  #
  # Create a class deriving from +Pointer_+. The parameter +target+ is assigned to
  # the corresponding attribute of the resulting class.
  #
  # @param [Class] target The native type of the complex components.
  #
  # @return [Class] A class deriving from +Pointer_+.
  #
  # @see Pointer_
  # @see Pointer_.target
  def Pointer( target )
    p = Class.new Pointer_
    p.target = target
    p
  end

  module_function :Pointer

end
