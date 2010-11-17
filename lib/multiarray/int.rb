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

  # Class for representing native integers
  class INT_ < Element

    class << self

      # Number of bits of this integer
      #
      # @return [Integer] Number of bits of this integer.
      attr_accessor :bits

      # Boolean indicating whether this is a signed integer or not
      #
      # @return [Boolean] Boolean indicating whether this is a
      # signed integer or not.
      attr_accessor :signed

      # Memory type required to store elements of this type
      #
      # @return [Class] Returns +Malloc+.
      #
      # @private
      def memory
        Malloc
      end

      # Get storage size to store an element of this type
      #
      # @return [Integer] Returns +1+.
      #
      # @private
      def storage_size
        ( bits + 7 ).div 8
      end

      # Get default value for elements of this type
      #
      # @return [Object] Returns +0+.
      #
      # @private
      def default
        0
      end

      # Get corresponding maximal integer type
      #
      # @return [Class] Returns 32 bit integer or self whichever has more bits.
      #
      # @private
      def maxint
        Hornetseye::INT [ 32, bits ].max, signed
      end

      # Compute balanced type for binary operation
      #
      # @param [Class] other Other native datatype to coerce with.
      #
      # @return [Class] Result of coercion.
      #
      # @private
      def coercion( other )
        if other < INT_
          Hornetseye::INT [ bits, other.bits ].max, ( signed or other.signed )
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
        if other < INT_
          return other, self
        else
          super other
        end
      end

      DIRECTIVES = { [  8, true  ] => 'c',
                     [  8, false ] => 'C',
                     [ 16, true  ] => 's',
                     [ 16, false ] => 'S',
                     [ 32, true  ] => 'i',
                     [ 32, false ] => 'I',
                     [ 64, true  ] => 'q',
                     [ 64, false ] => 'Q' }

      # Directive for packing/unpacking elements of this type
      #
      # @private
      def directive
        retval = DIRECTIVES[ [ bits, signed ] ]
        raise "No directive for packing/unpacking #{inspect}" unless retval
        retval
      end

      IDENTIFIER = { [  8, true  ] => 'BYTE',
                     [  8, false ] => 'UBYTE',
                     [ 16, true  ] => 'SINT',
                     [ 16, false ] => 'USINT',
                     [ 32, true  ] => 'INT',
                     [ 32, false ] => 'UINT',
                     [ 64, true  ] => 'LONG',
                     [ 64, false ] => 'ULONG' }

      # Get string with information about this class
      #
      # @return [String] Returns string with information about this class (e.g.
      #         "BYTE").
      def inspect
        unless bits.nil? or signed.nil?
          retval = IDENTIFIER[ [ bits, signed ] ] ||
                   "INT(#{bits.inspect},#{ signed ? 'SIGNED' : 'UNSIGNED' })"
          ( class << self; self; end ).instance_eval do
            define_method( :inspect ) { retval }
          end
          retval
        else
          super
        end
      end

      # Get unique descriptor of this class
      #
      # @param [Hash] hash Labels for any variables.
      #
      # @return [String] Descriptor of this class.
      #
      # @private
      def descriptor( hash )
        unless bits.nil? or signed.nil?
          inspect
        else
          super hash
        end
      end

      # Test equality of classes
      #
      # @param [Object] other Object to compare with.
      #
      # @return [Boolean] Boolean indicating whether classes are equal.
      def ==( other )
        other.is_a? Class and other < INT_ and
          bits == other.bits and signed == other.signed
      end

      # Compute hash value for this class
      #
      # @return [Fixnum] Hash value
      #
      # @private
      def hash
        [ :INT_, bits, signed ].hash
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

    def times( &action )
      get.times &action
      self
    end

    def upto( other, &action )
      get.upto other.get, &action
      self
    end

    # Namespace containing method for matching elements of type INT_
    #
    # @see INT_
    #
    # @private
    module Match

      # Method for matching elements of type INT_
      #
      # @param [Array<Object>] *values Values to find matching native element
      #        type for.
      #
      # @return [Class] Native type fitting all values.
      #
      # @see INT_
      #
      # @private
      def fit( *values )
        if values.all? { |value| value.is_a? Integer }
          bits = 8
          ubits = 8
          signed = false
          values.each do |value|
            bits *= 2 until ( -2**(bits-1) ... 2**(bits-1) ).include? value
            if value < 0
              signed = true
            else
              ubits *= 2 until ( 0 ... 2**ubits ).include? value
            end
          end
          bits = signed ? bits : ubits
          if bits <= 64
            Hornetseye::INT bits, signed
          else
            super *values
          end
        else
          super *values
        end
      end

    end

    Node.extend Match

  end

  # Boolean constant to use as a parameter for creating integer classes
  #
  # The value is +false+.
  #
  # @see #INT
  UNSIGNED = false

  # Boolean constant to use as a parameter for creating integer classes
  #
  # The value is +true+.
  #
  # @see #INT
  SIGNED   = true

  # Create a class deriving from +INT_+ or instantiate an +INT+ object
  #
  # @overload INT( bits, signed )
  #   Create a class deriving from +INT_+. The aprameters +bits+ and +signed+
  #   are assigned to the corresponding attributes of the resulting class.
  #   @param [Integer] bits Number of bits of native integer.
  #   @param [Boolean] signed Specify +UNSIGNED+ or +SIGNED+ here.
  #   @return [Class] A class deriving from +INT_+.
  #
  # @overload INT( value )
  #   This is a shortcut for +INT.new( value )+.
  #   @param [Integer] value Initial value for integer object.
  #   @return [INT] Wrapped integer value.
  #
  # @see INT_
  # @see INT_.bits
  # @see INT_.signed
  def INT( arg, signed = nil )
    if signed.nil?
      INT.new arg
    else
      retval = Class.new INT_
      retval.bits = arg
      retval.signed = signed
      retval
    end
  end

  module_function :INT

  # 8-bit signed integer
  BYTE  = INT  8, SIGNED

  # 8-bit unsigned integer
  UBYTE = INT  8, UNSIGNED

  # 16-bit signed integer
  SINT  = INT 16, SIGNED

  # 16-bit unsigned integer
  USINT = INT 16, UNSIGNED

  # 32-bit signed integer
  INT   = INT 32, SIGNED

  # 32-bit unsigned integer
  UINT  = INT 32, UNSIGNED

  # 64-bit signed integer
  LONG  = INT 64, SIGNED

  # 64-bit unsigned integer
  ULONG = INT 64, UNSIGNED

  # Shortcut for constructor
  #
  # The method calls +BYTE.new+.
  #
  # @param [Integer] value Integer value.
  #
  # @return [BYTE] The wrapped integer value.
  #
  # @private
  def BYTE( value )
    BYTE.new value
  end

  # Shortcut for constructor
  #
  # The method calls +UBYTE.new+.
  #
  # @param [Integer] value Integer value.
  #
  # @return [UBYTE] The wrapped integer value.
  #
  # @private
  def UBYTE( value )
    UBYTE.new value
  end

  # Shortcut for constructor
  #
  # The method calls +SINT.new+.
  #
  # @param [Integer] value Integer value.
  #
  # @return [SINT] The wrapped integer value.
  #
  # @private
  def SINT( value )
    SINT.new value
  end

  # Shortcut for constructor
  #
  # The method calls +USINT.new+.
  #
  # @param [Integer] value Integer value.
  #
  # @return [USINT] The wrapped integer value.
  #
  # @private
  def USINT( value )
    USINT.new value
  end

  # Shortcut for constructor
  #
  # The method calls +UINT.new+.
  #
  # @param [Integer] value Integer value.
  #
  # @return [UINT] The wrapped integer value.
  #
  # @private
  def UINT( value )
    UINT.new value
  end

  # Shortcut for constructor
  #
  # The method calls +LONG.new+.
  #
  # @param [Integer] value Integer value.
  #
  # @return [LONG] The wrapped integer value.
  #
  # @private
  def LONG( value )
    LONG.new value
  end

  # Shortcut for constructor
  #
  # The method calls +ULONG.new+.
  #
  # @param [Integer] value Integer value.
  #
  # @return [ULONG] The wrapped integer value.
  #
  # @private
  def ULONG( value )
    ULONG.new value
  end

  module_function :BYTE
  module_function :UBYTE
  module_function :SINT
  module_function :USINT
  module_function :UINT
  module_function :LONG
  module_function :ULONG


end
