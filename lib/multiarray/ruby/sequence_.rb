module Hornetseye

  module Ruby

    class Sequence_

      class << self

        attr_accessor :front

        def alloc( n = 1 )
          @front.element_type.delegate.alloc n * @front.num_elements
        end

        def typecode
          @front.element_type.typecode.delegate
        end

        def storage_size
          @front.element_type.delegate.storage_size * @front.num_elements
        end

        def default
          retval = @front.new
          retval.set
          retval
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
          for i in 0 ... self.class.front.num_elements
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
          unless ( 0 ... self.class.front.num_elements ).member? indices.last
            raise "Index must be in 0 ... #{num_elements} " +
                  "(was #{indices.last.inspect})"
          end
          element_storage = @storage + indices.last * self.class.front.stride *
                            self.class.typecode.storage_size
          @parent.class.element_type.new( nil, :storage => element_storage ).
            sel *indices.first( indices.size - 1 )
        end
      end

      def op( *args, &action )
        for i in 0 ... self.class.front.num_elements
          sub_args = args.collect do |arg|
            arg.is_a?( Hornetseye::Sequence_ ) ? arg.sel( i ).get : arg
          end
          sel( i ).op *sub_args, &action
        end
      end

    end

  end

end
