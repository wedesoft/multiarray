module Hornetseye

  module Ruby

    class INT_ < Hornetseye::INT_

      class << self

        # Get descriptor for packing/unpacking native values
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

      def initialize( value = nil, options = {} )
        @malloc = options[ :malloc ] || Malloc.new( bytesize )
        super value
      end

      def get
        @malloc.read( bytesize ).unpack( descriptor ).first
      end

      def set( value = typecode.default )
        @malloc.write [ value ].pack( descriptor )
      end

      def sel
        self
      end

      # @private
      def descriptor
        self.class.descriptor
      end

    end

  end

end
