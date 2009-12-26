module Hornetseye

  module Ruby

    class INT_

      class << self

        attr_accessor :front

        # @private
        def alloc( n = 1 )
          Malloc.new n * storage_size
        end

        def typecode
          self
        end

        # @private
        def storage_size
          ( @front.bits + 7 ).div 8
        end

        def default
          0
        end

      end

      def initialize( parent, options = {} )
        @storage = options[ :storage ] || self.class.alloc
      end

      # Get descriptor for packing/unpacking native values
      #
      # @private
      def descriptor
        case [ self.class.front.bits, self.class.front.signed ]
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

      def set( value = self.class.default )
        @storage.write [ value ].pack( descriptor )
        value
      end

      def sel
        self
      end

      def op( *args, &action )
        instance_exec *args, &action
        self
      end

    end

  end

end
