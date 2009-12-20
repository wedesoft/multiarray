module Hornetseye

  module Ruby

    class OBJECT

      class << self

        def alloc( n = 1 )
          List.new n
        end

      end

      def initialize( options = {} )
        @storage = options[ :storage ] || self.class.alloc
      end

      def get
        @storage.read
      end

      def set( value )
        @storage.write value
      end

    end

  end

end
