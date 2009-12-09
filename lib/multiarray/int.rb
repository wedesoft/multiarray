module Hornetseye

  class INT_ < DescriptorType

    class << self

      attr_accessor :bits
      attr_accessor :signed

      def memory
        Memory
      end

      def bytesize
        bits / 8
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
