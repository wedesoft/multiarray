module Hornetseye

  module Ruby

    class OBJECT

      class << self

        def alloc( n = 1 )
          Array.new n
        end

      end

      def initialize( options = {} )
        @array = options[ :array ] || self.class.alloc
        @offset = options[ :offset ] || 0
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
