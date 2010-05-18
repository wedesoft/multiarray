module Hornetseye

  class OBJECT < Element

    class << self

      def inspect
        'OBJECT'
      end

      def descriptor( hash )
        'OBJECT'
      end

      def memory
        List
      end

      def storage_size
        1
      end

      def default
        nil
      end

      def coercion( other )
        if other < Sequence_
          other.coercion self
        else
          self
        end
      end

      def coerce( other )
        return self, self
      end

    end

    def inspect
      "OBJECT(#{@value.inspect})"
    end

    def descriptor( hash )
      "OBJECT(#{@value.to_s})"
    end

    module Match

      def fit( *values )
        OBJECT
      end

    end

    Node.extend Match

  end

end
