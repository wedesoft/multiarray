module Hornetseye

  # Abstract class for representing native integers
  #
  # @see #INT
  #
  # @abstract
  class INT_ < DescriptorType

    class << self

      # The number of bits of native integers represented by this class
      #
      # @return [Integer] Number of bits of native integer.
      #
      # @see signed
      #
      # @private
      attr_accessor :bits

      # A boolean indicating whether this is a signed integer or not
      #
      # @return [FalseClass,TrueClass] Boolean indicating whether this is a
      # signed integer.
      #
      # @see bits
      #
      # @private
      attr_accessor :signed

      # Returns the type of storage object for storing values
      #
      # @return [Class] Returns +Memory+.
      #
      # @private
      def memory
        Memory
      end

      # Number of bytes for storing an object of this type
      #
      # @return [Integer] Number of bytes to store a native integer of this
      # type.
      #
      # @private
      def bytesize
        ( bits + 7 ).div 8
      end

      # Default value for integers
      #
      # @return [Integer] Returns +0+.
      #
      # @private
      def default
        0
      end

      # Get string with information about this type
      #
      # @return [String] Information about this integer type.
      def to_s
        case [ bits, signed ]
        when [  8, true  ]
          'BYTE'
        when [  8, false ]
          'UBYTE'
        when [ 16, true  ]
          'SINT'
        when [ 16, false ]
          'USINT'
        when [ 32, true  ]
          'INT'
        when [ 32, false ]
          'UINT'
        when [ 64, true  ]
          'LONG'
        when [ 64, false ]
          'ULONG'
        else
          "INT(#{bits.to_s},#{ signed ? "SIGNED" : "UNSIGNED" })"
        end
      end

      # Get string with information about this type
      #
      # @return [String] Information about this integer type.
      def inspect
        to_s
      end

      # Get descriptor for packing/unpacking native values
      #
      # @see DescriptorType.pack
      # @see DescriptorType.unpack
      #
      # @private
      def descriptor
        case [ bits, signed ]
        when [  8, true  ]
          'c'
        when [  8, false ]
          'C'
        when [ 16, true  ]
          's'
        when [ 16, false ]
          'S'
        when [ 32, true  ]
          'i'
        when [ 32, false ]
          'I'
        when [ 64, true  ]
          'q'
        when [ 64, false ]
          'Q'
        else
          raise "No descriptor for packing/unpacking #{self}"
        end
      end

    end

  end

end
