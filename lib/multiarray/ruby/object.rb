module Hornetseye

  module Ruby

    class OBJECT

      def initialize( typecode, options = {} )
        @array = options[ :array ] || alloc
        @offset = options[ :offset ] || 0
      end

      def alloc( n = 1 )
        Array.new n
      end

      def get
        @array[ @offset ]
      end

      def set( value )
        @array[ @offset ] = value
      end

    end

  end

end
