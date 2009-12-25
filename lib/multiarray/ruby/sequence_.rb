module Hornetseye

  module Ruby

    class Sequence_

      class << self

        attr_accessor :element_type

        attr_accessor :num_elements

        attr_accessor :stride

        def alloc( n = 1 )
          element_type.alloc n * num_elements
        end

        def typecode
          element_type.typecode
        end

      end

      def initialize( options = {} )
        @storage = options[ :storage ] || self.class.alloc
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
          unless ( 0 ... self.class.num_elements ).member? indices.last
            raise "Index must be in 0 ... #{num_elements} " +
                  "(was #{indices.last.inspect})"
          end
          element_storage = @storage + indices.last * self.class.stride *
                            self.class.typecode.storage_size
          self.class.element_type.new( :storage => element_storage ).
            sel *indices.first( indices.size - 1 )
        end
      end

    end

  end

end
