module Hornetseye

  module Ruby

    # Delegate class for handling native arrays in Ruby
    #
    # @see Hornetseye::Sequence_
    #
    # @private
    # @abstract
    class Sequence_

      class << self

        # Return the proxy class which this class is a delegate of
        #
        # @return [Class] The proxy class.
        #
        # @see Hornetseye::Sequence_
        #
        # @private
        attr_accessor :front

        # Allocate storage for delegate object
        #
        # @param [Integer] n Number of arrays to store.
        # @return [Hornetseye::Malloc,Hornetseye::Ruby::List] Object for
        # storing array(s).
        #
        # @private
        def alloc( n = 1 )
          @front.element_type.delegate.alloc n * @front.num_elements
        end

        # Returns the delegate for element type of arrays or +self+.
        #
        # @return [Class] Returns delegate for element type.
        #
        # @private
        def typecode
          @front.element_type.typecode.delegate
        end

        # Size of storage required for this array.
        #
        # @return [Integer] Size of storage for storing the elements of this
        # array.
        #
        # @private
        def storage_size
          @front.element_type.delegate.storage_size * @front.num_elements
        end

        # Get default value for this array type.
        #
        # @return [Object] Returns a multi-dimensional array filled with the
        # default value of the element type.
        #
        # @private
        def default
          retval = @front.new
          retval.set
          retval
        end

      end

      # Construct delegate object for storing the data of the array
      #
      # @param [Hornetseye::Sequence_] parent Proxy object for this delegate.
      # @option options [Hornetseye::Malloc,Hornetseye::Ruby::List] :storage
      # (self.class.alloc) View on storage object to store the data of the
      # array.
      #
      # @private
      def initialize( parent, options = {} )
        @parent = parent
        @storage = options[ :storage ] || self.class.alloc
      end

      # Get the proxy object of this delegate
      #
      # @return [Hornetseye::Sequence_] Proxy object of this delegate.
      #
      # @see #set
      #
      # @private
      def get
        @parent
      end

      # Set value of delegate
      #
      # @param [Hornetseye::Sequence_,Array] value Value to set delegate to.
      # @return [Hornetseye::Sequence_,Array] The parameter +value+.
      #
      # @see #get
      #
      # @private
      def set( value = self.class.typecode.default )
        if value.is_a? Array
          for i in 0 ... self.class.front.num_elements
            element( i ).set i < value.size ?
                             value[ i ] : self.class.typecode.default
          end
        else
          op( value ) { |x| set x }
        end
        value
      end

      # Get view for an element of the array represented by this delegate
      #
      # @param [Array<Integer>] *indices Index/indices to select the element.
      # @return [Sequence_,Object] Get delegate object viewing the specified
      # element.
      #
      # @private
      def element( *indices )
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
            element *indices.first( indices.size - 1 )
        end
      end

      # Perform operation on the data type
      #
      # @private
      def op( *args, &action )
        for i in 0 ... self.class.front.num_elements
          sub_args = args.collect do |arg|
            arg.is_a?( Hornetseye::Sequence_ ) ? arg.element( i ).get : arg
          end
          element( i ).op *sub_args, &action
        end
      end

    end

  end

end
