module Hornetseye

  # Namespace with objects for performing computations in Ruby
  #
  # @private
  module Ruby

    # Delegate class for handling Ruby objects
    #
    # @see Hornetseye::OBJECT
    #
    # @private
    class OBJECT

      class << self

        # Allocate storage for delegate object
        #
        # @param [Integer] n Number of elements to store.
        # @return [List] Object for storing the element(s).
        #
        # @private
        def alloc( n = 1 )
          List.new n
        end

        # Returns the delegate for element type of arrays or +self+
        #
        # @return [Class] Returns +self+.
        #
        # @private
        def typecode
          self
        end

        # Size of storage required to store an element of this type
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

        # Return the proxy class which this class is a delegate of
        #
        # @return [Class] The proxy class.
        #
        # @see Hornetseye::OBJECT
        #
        # @private
        def front
          Hornetseye::OBJECT
        end

      end

      # Construct delegate object for storing Ruby objects
      #
      # @param [Hornetseye::OBJECT] parent Proxy object for this delegate.
      # @option options [List] :storage (self.class.alloc) View on Ruby array
      # to store delegate objects.
      #
      # @private
      def initialize( parent, options = {} )
        @storage = options[ :storage ] || self.class.alloc
      end

      # Retrieve the Ruby value
      #
      # @return [Object] Ruby value of delegate.
      #
      # @see #set
      #
      # @private
      def get
        @storage.read
      end

      # Set the Ruby value
      #
      # @param [Object] value Ruby value to set delegate to.
      # @return [Object] The parameter +value+.
      #
      # @see #get
      #
      # @private
      def set( value = self.class.default )
        @storage.write value
      end

      # Get view for an element or return +self+ if this is not an array
      #
      # @return [OBJECT] Returns +self+.
      #
      # @private
      def element
        self
      end

      # Perform operation on the data type
      #
      # @private
      def op( *args, &action )
        instance_exec *args, &action
        self
      end

    end

  end

end
