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

  # Class for representing native floating point numbers
  class FLOAT_ < Element

    class << self

      # Boolean indicating whether this number is single or double precision
      #
      # @return [Boolean] +true+ for double precision, +false+ for single precision.
      #
      # @private
      attr_accessor :double

      # Memory type required to store elements of this type
      #
      # @return [Class] Returns +Malloc+.
      #
      # @private
      def memory_type
        Malloc
      end

      # Get storage size to store an element of this type
      #
      # @return [Integer] Returns +4+ or +8+.
      #
      # @private
      def storage_size
        double ? 8 : 4
      end

      # Get default value for elements of this type
      #
      # @return [Object] Returns +0.0+.
      #
      # @private
      def default
        0.0
      end

      # Compute balanced type for binary operation
      #
      # @param [Class] other Other native datatype to coerce with.
      #
      # @return [Class] Result of coercion.
      #
      # @private
      def coercion( other )
        if other < FLOAT_
          Hornetseye::FLOAT( ( double or other.double ) )
        elsif other < INT_
          self
        else
          super other
        end
      end

      # Type coercion for native elements
      #
      # @param [Class] other Other type to coerce with.
      #
      # @return [Array<Class>] Result of coercion.
      #
      # @private
      def coerce( other )
        if other < FLOAT_
          return other, self
        elsif other < INT_
          return self, self
        else
          super other
        end
      end

      # Convert to type based on floating point numbers
      #
      # @return [Class] Corresponding type based on floating point numbers.
      #
      # @private
      def float
        self
      end

      # Directive for packing/unpacking elements of this type
      #
      # @return [String] Returns 'f' or 'd'.
      #
      # @private
      def directive
        double ? 'd' : 'f'
      end

      # Return string with information about this class
      #
      # @return [String] Returns a string (e.g. "SFLOAT").
      def inspect
        "#{ double ? 'D' : 'S' }FLOAT"
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

      # Test equality of classes
      #
      # @param [Object] other Object to compare with.
      #
      # @return [Boolean] Boolean indicating whether classes are equal.
      def ==( other )
        other.is_a? Class and other < FLOAT_ and double == other.double
      end

      # Compute hash value for this class
      #
      # @return [Fixnum] Hash value
      #
      # @private
      def hash
        [ :FLOAT_, double ].hash
      end

      # Equality for hash operations
      #
      # @param [Object] other Object to compare with.
      #
      # @return [Boolean] Returns +true+ if objects are equal.
      #
      # @private
      def eql?( other )
        self == other
      end

    end

    # Namespace containing method for matching elements of type FLOAT_
    #
    # @see FLOAT_
    #
    # @private
    module Match

      # Method for matching elements of type FLOAT_
      #
      # @param [Array<Object>] *values Values to find matching native element
      #        type for.
      #
      # @return [Class] Native type fitting all values.
      #
      # @see FLOAT_
      #
      # @private
      def fit( *values )
        if values.all? { |value| value.is_a? Float or value.is_a? Integer }
          if values.any? { |value| value.is_a? Float }
            DFLOAT
          else
            super *values
          end
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
        if self < FLOAT_ and context < FLOAT_
          context
        else
          super context
        end
      end

    end

    Node.extend Match

  end

  # Boolean constant to use as a parameter for creating floating point classes
  #
  # The value is +false+.
  #
  # @see #FLOAT
  SINGLE = false

  # Boolean constant to use as a parameter for creating floating point classes
  #
  # The value is +true+.
  #
  # @see #FLOAT
  DOUBLE = true

  # Create a class deriving from +FLOAT_+
  #
  # Create a class deriving from +FLOAT_+. The parameters +double+ is assigned to the
  # corresponding attributes of the resulting class.
  #
  # @param [Boolean] double Specify +SINGLE+ or +DOUBLE+ here.
  #
  # @return [Class] A class deriving from +FLOAT_+.
  #
  # @see FLOAT_
  # @see FLOAT_.double
  def FLOAT( double )
    retval = Class.new FLOAT_
    retval.double = double
    retval
  end

  module_function :FLOAT

  # Single-precision floating-point number
  SFLOAT = FLOAT SINGLE

  # Double-precision floating-point number
  DFLOAT = FLOAT DOUBLE

  # Shortcut for constructor
  #
  # The method calls +SFLOAT.new+.
  #
  # @param [Float] value Floating point value.
  #
  # @return [SFLOAT] The wrapped floating point value.
  #
  # @private
  def SFLOAT( value )
    SFLOAT.new value
  end

  module_function :SFLOAT

  # Shortcut for constructor
  #
  # The method calls +DFLOAT.new+.
  #
  # @param [Float] value Floating point value.
  #
  # @return [DFLOAT] The wrapped floating point value.
  #
  # @private
  def DFLOAT( value )
    DFLOAT.new value
  end

  module_function :DFLOAT

end
