module Hornetseye

  module Ruby

    # Class for creating views on Ruby arrays
    #
    # @private
    class List

      # Create zero-offset view on a Ruby array
      #
      # @param size Number of elements of the view.
      # @option options [Array<Object>] :array The Ruby array.
      # @option options [Integer] :offset Offset of the view.
      #
      # @private
      def initialize( size, options = {} )
        @array = options[ :array ] || [ nil ] * size
        @offset = options[ :offset ] || 0
      end

      # Retrieve an element from the array
      #
      # @return [Object] The element from the array.
      #
      # @see #write
      # @see Malloc#read
      #
      # @private
      def read
        @array[ @offset ]
      end

      # Store an element in the array
      #
      # @param [Object] value The Ruby object to store.
      # @return [Object] Returns the parameter +value+.
      #
      # @see #read
      # @see Malloc#write
      #
      # @private
      def write( value )
        @array[ @offset ] = value
        value
      end

      # Create a new view with the specified offset
      #
      # @param [Integer] offset A non-negative offset.
      # @return [List] A new view for the specified part of the array.
      #
      # @see Memory#+
      # @private
      def +( offset )
        List.new 0, :array => @array, :offset => @offset + offset
      end

    end

  end

end
