module Hornetseye

  class INT_ < Element

    class << self

      attr_accessor :bits
      attr_accessor :signed

      def memory
        Malloc
      end

      def storage_size
        ( bits + 7 ).div 8
      end

      def default
        0
      end

      def coercion( other )
        if other < INT_
          INT [ bits, other.bits ].max, ( signed or other.signed )
        else
          super other
        end
      end

      def directive
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
          raise "No directive for packing/unpacking #{inspect}"
        end
      end

      def inspect
        if bits != nil and signed != nil
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

      def descriptor( hash )
        if bits != nil and signed != nil
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
            "INT(#{bits.to_s},#{ signed ? 'SIGNED' : 'UNSIGNED' })"
          end
        else
          super
        end
      end

      def ==( other )
        other.is_a? Class and other < INT_ and
          bits == other.bits and signed == other.signed
      end

      def hash
        [ :INT_, bits, signed ].hash
      end

      def eql?( other )
        self == other
      end

    end

    module Match

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

  def INT( bits, signed )
    retval = Class.new INT_
    retval.bits = bits
    retval.signed = signed
    retval
  end

  module_function :INT

  UNSIGNED = false
  SIGNED   = true

  BYTE  = INT  8, SIGNED
  UBYTE = INT  8, UNSIGNED
  SINT  = INT 16, SIGNED
  USINT = INT 16, UNSIGNED
  INT   = INT 32, SIGNED
  UINT  = INT 32, UNSIGNED
  LONG  = INT 64, SIGNED
  ULONG = INT 64, UNSIGNED

end
