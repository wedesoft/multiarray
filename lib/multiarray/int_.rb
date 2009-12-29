module Hornetseye

  # Abstract class for representing native integers
  #
  # @see #INT
  #
  # @abstract
  class INT_ < Type

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

      # Get delegate class to this class
      #
      # @return [Class] Delegate class.
      #
      # @see Hornetseye::Ruby::INT_
      #
      # @private
      def delegate
        mode = ( Thread.current[ :mode ] || Ruby )
        mode.send :INT, self
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

    end

  end

end
