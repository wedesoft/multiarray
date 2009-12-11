module Hornetseye

  # Abstract class for representing native integers.
  #
  # @see #INT
  # @private
  # @abstract
  class INT_ < DescriptorType

    class << self

      # The number of bits of native integers represented by this class.
      #
      # @return [Integer] Number of bits of native integer.
      #
      # @see signed
      attr_accessor :bits

      # A boolean indicating whether this is a signed integer or not.
      #
      # @return [FalseClass,TrueClass] Boolean indicating whether this is a
      # signed integer.
      #
      # @see bits
      attr_accessor :signed

      # Returns the type of storage object for storing values.
      #
      # @return [Class] Returns +Memory+.
      #
      # @private
      def memory
        Memory
      end

      def bytesize
        bits / 8
      end

      # @private
      def default
        0
      end

      def inspect
        to_s
      end

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

  UNSIGNED = false

  SIGNED   = true

  # Create a class deriving from +INT_+. The parameters +bits+ and +signed+
  # are assigned to the corresponding attributes of the resulting class.
  #
  # @return [Class] A class deriving from +INT_+.
  #
  # @see INT_
  # @see INT_.bits
  # @see INT_.signed
  def INT( bits, signed )
    retval = Class.new INT_
    retval.bits   = bits
    retval.signed = signed
    retval
  end

  module_function :INT

  BYTE  = INT  8, SIGNED
  UBYTE = INT  8, UNSIGNED
  SINT  = INT 16, SIGNED
  USINT = INT 16, UNSIGNED
  INT   = INT 32, SIGNED
  UINT  = INT 32, UNSIGNED
  LONG  = INT 64, SIGNED
  ULONG = INT 64, UNSIGNED

end
