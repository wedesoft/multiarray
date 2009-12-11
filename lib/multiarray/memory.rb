module Hornetseye

  # Class for creating views on raw memory
  #
  # @see Storage
  # @see List
  # @private
  class Memory < Storage

    class << self

      # Create a +Memory+ object viewing a new +Malloc+ object
      #
      # @param [Integer] bytesize Number of bytes to allocate.
      # @return [Memory] The new +Memory+ object.
      #
      # @see Malloc
      # @private
      def alloc( bytesize )
        Memory.new Malloc.new( bytesize )
      end

      # Create a +Memory+ object viewing a new +Malloc+ object initialised with
      # the content of a string
      #
      # @param [String] str A Ruby string with data to write to memory.
      # object.
      # @return [Memory] The new +Memory+ object initialised with the data.
      #
      # @private
      def import( str )
        retval = alloc str.bytesize
        retval.import str
        retval
      end

    end

    # Create zero-offset view on a +Malloc+ object
    #
    # @param [Malloc] ptr A +Malloc+ object with the raw data.
    #
    # @private
    def initialize( ptr )
      super ptr
    end

    # Read an element from the memory
    #
    # @param [Type] typecode Information for converting native data type to
    # a Ruby object.
    # @return [Object] The element from the memory.
    #
    # @see #store
    # @see List#load
    # @private
    def load( typecode )
      typecode.unpack export( typecode.bytesize )
    end

    # Write an element to the memory
    #
    # @param [Type] typecode Information for converting Ruby object to native
    # data type.
    # @return [Object] Returns the parameter +value+.
    #
    # @see #load
    # @see List#store
    # @private
    def store( typecode, value )
      import typecode.pack( value )
      value
    end

    # Write multiple elements to memory
    #
    # @param [String] data A ruby string with data to write to memory.
    # @return [String] The parameter +data+.
    #
    # @see #export
    # @see List#import
    # @private
    def import( data )
      @data.write data
    end

    # Read multiple elements from memory
    #
    # @param [Integer] bytesize Number of bytes to read from memory.
    # @return [String] A Ruby string with the resulting data.
    #
    # @see #import
    # @see List#export
    # @private
    def export( bytesize )
      @data.read bytesize
    end

    # Create a new view with the specified offset
    #
    # @param [Integer] offset A non-negative offset.
    # @return [Memory] A new view for the specified part of the memory.
    #
    # @see List#+
    # @private
    def +( offset )
      Memory.new @data + offset
    end

  end

end
