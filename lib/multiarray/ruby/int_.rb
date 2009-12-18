module Hornetseye

  module Ruby

    class INT_

      def initialize( typecode, options = {} )
        @typecode = typecode
        @malloc = options[ :malloc ] || alloc
      end

      # @private
      def alloc( n = 1 )
        Malloc.new n * @typecode.bytesize
      end

      # Get descriptor for packing/unpacking native values
      #
      # @private
      def descriptor
        case [ @typecode.bits, @typecode.signed ]
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

      def get
        @malloc.read( @typecode.bytesize ).unpack( descriptor ).first
      end

      def set( value )
        @malloc.write [ value ].pack( descriptor )
      end

      def sel
        self
      end

    end

  end

end
