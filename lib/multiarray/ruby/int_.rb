module Hornetseye

  module Ruby

    # Delegate class for handling native integers in Ruby
    #
    # @see Hornetseye::INT_
    #
    # @abstract
    # @private
    class INT_

      class << self

        # Return the proxy class which this class is a delegate of
        #
        # @return [Class] The proxy class.
        #
        # @see Hornetseye::INT_
        #
        # @private
        attr_accessor :front

        # Allocate storage for delegate object
        #
        # @param [Integer] n Number of elements to store.
        # @return [Hornetseye::Malloc] Object for storing the element(s).
        #
        # @private
        def alloc( n = 1 )
          Malloc.new n * storage_size
        end

        # Returns the delegate for element type of arrays or +self+
        #
        # @return [Class] Returns +self+.
        #
        # @private
        def typecode
          self
        end

        # Get number of bytes memory required to store integer
        #
        # @return [Integer] Number of bytes.
        #
        # @private
        def storage_size
          ( @front.bits + 7 ).div 8
        end

        # Default value for integers
        #
        # @return [Object] Returns +0+.
        #
        # @private
        def default
          0
        end

      end

      # Construct delegate object for storing native integers
      #
      # @param [Hornetseye::INT_] parent Proxy object for this delegate.
      # @option options [Hornetseye::Malloc] :storage (self.class.alloc) View
      # on Ruby array to store delegate objects.
      #
      # @private
      def initialize( parent, options = {} )
        @storage = options[ :storage ] || self.class.alloc
      end

      # Get descriptor for packing/unpacking native values
      #
      # The descriptor is used when calling +Array#pack+ or +String#unpack+.
      #
      # @return [String] Descriptor for packing/unpacking native values.
      #
      # @private
      def descriptor
        case [ self.class.front.bits, self.class.front.signed ]
        when [  8, true  ]
          'c'
        when [  8, false ]
          'C'
        when [ 16, true  ]
          's'
        when [ 16, false ]
          'S'
        when [ 32, true  ]
          'i'
        when [ 32, false ]
          'I'
        when [ 64, true  ]
          'q'
        when [ 64, false ]
          'Q'
        else
          raise "No descriptor for packing/unpacking #{self}"
        end
      end

      # Retrieve the native integer and convert to Ruby value
      #
      # @return [Integer] Ruby value of delegate.
      #
      # @see #set
      #
      # @private
      def get
        @storage.read( self.class.storage_size ).unpack( descriptor ).first
      end

      # Convert Ruby value to native integer and store it
      #
      # @param [Integer] value Ruby value to set delegate to.
      # @return [Integer] The parameter +value+.
      #
      # @see #get
      #
      # @private
      def set( value = self.class.default )
        @storage.write [ value ].pack( descriptor )
        value
      end

      # Get view for an element or return +self+ if this is not an array
      #
      # @return [INT_] Returns +self+.
      #
      # @private
      def element
        self
      end

      # Perform operation on the data type
      #
      # @param [Array<Object>] *args Parameters of operation.
      # @param [Proc] &action The operation to perform.
      # @return [INT_] Returns +self+.
      #
      # @private
      def op( *args, &action )
        instance_exec *args, &action
        self
      end

    end

  end

end
