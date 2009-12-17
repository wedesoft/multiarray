module Hornetseye

  module Ruby

    class OBJECT < Hornetseye::OBJECT

      class << self

        def alloc( n = 1 )
          Array.new n
        end

      end

      def initialize( value = nil, options = {} )
        @array = options[ :array ] || alloc
        @offset = options[ :offset ] || 0
        super value
      end

      def get
        @array[ @offset ]
      end

      def set( value = typecode.default )
        @array[ @offset ] = value
      end

    end

  end

end
