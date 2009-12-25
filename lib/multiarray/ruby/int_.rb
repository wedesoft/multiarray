module Hornetseye

  module Ruby

    class INT_

      class << self

        attr_accessor :bits

        attr_accessor :signed

        # @private
        def alloc( n = 1 )
          Malloc.new n * storage_size
        end

        def typecode
          self
        end

        # @private
        def storage_size
          ( bits + 7 ).div 8
        end

      end

      def initialize( options = {} )
        @storage = options[ :storage ] || self.class.alloc
      end

      # Get descriptor for packing/unpacking native values
      #
      # @private
      def descriptor
        case [ self.class.bits, self.class.signed ]
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
        @storage.read( self.class.storage_size ).unpack( descriptor ).first
      end

      def set( value )
        @storage.write [ value ].pack( descriptor )
      end

      def sel
        self
      end

    end

  end

end
