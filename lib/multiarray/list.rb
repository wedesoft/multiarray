module Hornetseye
  
  # Class for creating views on Ruby arrays
  #
  # @private
  class List

    # Create view on a Ruby array
    #
    # @param [Integer] n Number of elements of the view.
    # @option options [Array<Object>] :array ([nil] * n) The Ruby array.
    # @option options [Integer] :offset (0) Offset of the view.
    #
    # @private
    def initialize( n, options = {} )
      @array = options[ :array ] || [ nil ] * n
      @offset = options[ :offset ] || 0
    end

    # Display information about this object
    #
    # @return [String] A string with information about the size of this view.
    def inspect
      "List(#{@array.size - @offset})"
    end

    # Retrieve and map element from the array
    #
    # @param [Class] type Native data type to create
    # @return [Type] The mapped element.
    def fetch( type )
      type.new read
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
    end

    # Create a new view with the specified offset
    #
    # @param [Integer] offset A non-negative offset.
    # @return [List] A new view for the specified part of the array.
    #
    # @see Malloc#+
    # @private
    def +( offset )
      List.new 0, :array => @array, :offset => @offset + offset
    end

  end

end
