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

        def storage_size
          element_type.storage_size * num_elements
        end

        def default
          retval = front.new
          retval.set
          retval
        end

        def front
          Hornetseye::Sequence element_type.front, num_elements
        end

      end

      def initialize( parent, options = {} )
        @parent = parent
        @storage = options[ :storage ] || self.class.alloc
      end

      # @private
      def get
        @parent
      end

      def set( value = self.class.typecode.default )
        if value.is_a? Array
          for i in 0 ... self.class.num_elements
            sel( i ).set i < value.size ?
                         value[ i ] : self.class.typecode.default
          end
        else
          op( value ) { |x| set x }
        end
        value
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
          @parent.class.element_type.new( nil, :storage => element_storage ).
            sel *indices.first( indices.size - 1 )
        end
      end

      def op( *args, &action )
        for i in 0 ... self.class.num_elements
          sub_args = args.collect do |arg|
            arg.is_a?( Hornetseye::Sequence_ ) ? arg.sel( i ).get : arg
          end
          sel( i ).op *sub_args, &action
        end
      end

    end

  end

end
