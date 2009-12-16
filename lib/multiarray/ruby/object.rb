module Hornetseye

  module Ruby

    class OBJECT < Hornetseye::OBJECT

      class << self

        #def delegate
        #  List
        #end

      end

      def initialize( value = nil, options = {} )
        @array = options[ :array ] || [ nil ]
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
