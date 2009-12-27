module Hornetseye

  module Ruby

    # Delegate class for Ruby objects.
    #
    # @private
    class OBJECT

      class << self

        def alloc( n = 1 )
          List.new n
        end

        def typecode
          self
        end

        # Size of storage required to store an element of this type.
        #
        # @return [Integer] Size of storage required. Returns +1+.
        #
        # @private
        def storage_size
          1
        end

        # Default value for Ruby objects
        #
        # @return [Object] Returns +nil+.
        #
        # @private
        def default
          nil
        end

        def front
          Hornetseye::OBJECT
        end

      end

      def initialize( parent, options = {} )
        @storage = options[ :storage ] || self.class.alloc
      end

      def get
        @storage.read
      end

      def set( value = self.class.default )
        @storage.write value
      end

      def element
        self
      end

      def op( *args, &action )
        instance_exec *args, &action
        self
      end

    end

  end

end
