module Hornetseye

  module Ruby

    class Sequence_ < Hornetseye::Sequence_

      class << self

        def alloc( n = 1 )
          element_type.alloc n * num_elements
        end

      end

      def initialize( value = nil, options = {} )
        @malloc = options[ :malloc ] || alloc
        raise 'What about array and offset?'
        super value
      end

      # @private
      def get
        self
      end

      def set( value = typecode.default )
        raise 'not implemented'
      end

      def sel( *indices )
        if indices.empty?
          self
        else
          unless ( 0 ... num_elements ).member? indices.last
            raise "Index must be in 0 ... #{num_elements} " +
                  "(was #{indices.last.inspect})"
          end
          raise 'not implemented'
          #element_storage = @storage + indices.last * stride * typecode.bytesize
          #element_type.wrap( element_storage ).sel *indices[ 0 ... -1 ]
        end
      end

    end

  end

end
