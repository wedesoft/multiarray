module Hornetseye

  class BOOL < Element

    class << self

      def fetch( ptr )
        new ptr.load( self ) != 0
      end

      def memory
        Malloc
      end

      def storage_size
        1
      end

      def default
        false
      end

      def directive
        'c'
      end

      def inspect
        'BOOL'
      end

      def descriptor( hash )
        'BOOL'
      end

    end

    def write( ptr )
      ptr.save UBYTE.new( get ? 1 : 0 )
    end

    module Match

      def fit( *values )
        if values.all? { |value| [ false, true ].member? value }
          BOOL
        else
          super *values
        end
      end

    end

    Node.extend Match

  end

end
