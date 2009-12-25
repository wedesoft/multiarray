module Hornetseye

  # Class for creating views on Ruby arrays
  #
  # @see Storage
  # @see Memory
  # @private
  class List

    # Create zero-offset view on a Ruby array
    #
    # @param [Array<Object>] arr A Ruby array.
    #
    # @private
    def initialize( size, options = {} )
      @array = options[ :array ] || [ nil ] * size
      @offset = options[ :offset ] || 0
    end

    # Retrieve an element from the array
    #
    # @param [Type] typecode This parameter is ignored.
    # @return [Object] The element from the array.
    #
    # @see #store
    # @see Memory#load
    # @private
    def read
      @array[ @offset ]
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
    def write( value )
      @array[ @offset ] = value
      value
    end

    # Store multiple elements in the array
    #
    # @param [Array<Object>] data A Ruby array with the new data.
    # @return [Array<Object>] The parameter +data+.
    #
    # @see #export
    # @see Memory#import
    # @private
    #def import( data )
    #  @data[ @offset ... @offset + data.size ] = data
    #end

    # Retrieve multiple elements from the array
    #
    # @param [Integer] size Number of elements to retrieve
    # @return [Array<Object>] A Ruby array with the elements.
    #
    # @see #import
    # @see Memory#export
    # @private
    #def export( size )
    #  @data[ @offset ... @offset + size ]
    #end

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
