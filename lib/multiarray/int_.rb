module Hornetseye

  # Abstract class for representing native integers
  #
  # @see #INT
  #
  # @abstract
  class INT_ < Type

    class << self

      # Get memory type for storing objects of this type
      #
      # @return [Class] Returns +Malloc+.
      #
      # @see Malloc
      #
      # @private
      def memory
        Malloc
      end

      def import( str )
        new str.unpack( descriptor ).first
      end

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

      # Get string with information about this type
      #
      # @return [String] Information about this integer type.
      def to_s
        if bits and signed != nil
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
            "INT(#{bits.inspect},#{ signed ? 'SIGNED' : 'UNSIGNED' })"
          end
        else
          super
        end
      end

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

      # Get string with information about this type
      #
      # @return [String] Information about this integer type.
      def inspect
        to_s
      end

      # Default value for Ruby objects
      #
      # @return [Integer] Returns +0+.
      #
      # @private
      def default
        0
      end

      #def fetch( ptr )
      #  new ptr.read( storage_size ).unpack( descriptor ).first
      #end

      def storage_size
        ( bits + 7 ).div 8
      end

      def ==( other )
        if other.is_a? Class
          if other < INT_ and bits == other.bits and signed == other.signed
            true
          else
            false
          end
        else
          false
        end
      end

      def hash
        [ :INT_, bits, signed ].hash
      end

      def eql?( other )
        self == other
      end
      
    end

    def store( ptr )
      ptr.write [ @value ].pack( self.class.descriptor )
      self
    end

  end

end
