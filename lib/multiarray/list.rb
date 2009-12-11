module Hornetseye

  # Class for creating views on Ruby arrays
  #
  # @see Storage
  # @see Memory
  # @private
  class List < Storage

    class << self

      # Create a +List+ object viewing a new Ruby array
      #
      # @param [Integer] size Number of elements the new Ruby array should
      # have.
      # @return [List] The new +List+ object.
      #
      # @private
      def alloc( size )
        new Array.new( size )
      end

      # Create a +List+ object viewing an existing Ruby array
      #
      # @param [Array] arr Existing Ruby array.
      # @return [List] The new +List+ object.
      #
      # @private
      def import( arr )
        new arr
      end

    end

    # Offset of this view
    #
    # @private
    attr_accessor :offset

    # Create zero-offset view on a Ruby array
    #
    # @param [Array] arr A Ruby array.
    #
    # @private
    def initialize( arr )
      super arr
      @offset = 0
    end

    # Retrieve an element from the array
    #
    # @param [Type] typecode This parameter is ignored.
    # @return [Object] The element from the array.
    #
    # @see #store
    # @see Memory#load
    # @private
    def load( typecode )
      @data[ @offset ]
    end

    # Store an element in the array
    #
    # @param [Type] typecode This parameter is ignored.
    # @param [Object] value The Ruby object to store.
    # @return [Object] Returns the parameter +value+.
    #
    # @see #load
    # @see Memory#store
    # @private
    def store( typecode, value )
      @data[ @offset ] = value
    end

    # Store multiple elements in the array
    #
    # @param [Array] data A Ruby array with the new data.
    # @return [Array] The parameter +data+.
    #
    # @see #export
    # @see Memory#import
    # @private
    def import( data )
      @data[ @offset ... @offset + data.size ] = data
    end

    # Retrieve multiple elements from the array
    #
    # @param [Integer] size Number of elements to retrieve
    # @return [Array] A Ruby array with the elements.
    #
    # @see #import
    # @see Memory#export
    # @private
    def export( size )
      @data[ @offset ... @offset + size ]
    end

    # Create a new view with the specified offset
    #
    # @param [Integer] offset A non-negative offset.
    # @return [List] A new view for the specified part of the array.
    #
    # @see Memory#+
    # @private
    def +( offset )
      retval = List.new @data
      retval.offset = @offset + offset
      retval
    end

  end

end
