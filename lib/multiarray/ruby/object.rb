module Hornetseye

  module Ruby

    class OBJECT

      class << self

        def alloc( n = 1 )
          List.new n
        end

        def typecode
          self
        end

        def storage_size
          1
        end

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
