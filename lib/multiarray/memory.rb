module Hornetseye

  # Class for creating views on raw memory.
  #
  # @see Storage
  # @see List
  # @private
  class Memory < Storage

    class << self

      # Create a +Memory+ object viewing a new +Malloc+ object.
      #
      # @param [Integer] bytesize Number of bytes to allocate.
      # @return [Memory] The new +Memory+ object.
      # @see Malloc
      def alloc( bytesize )
        Memory.new Malloc.new( bytesize )
      end

      # Create a +Memory+ object viewing a new +Malloc+ object initialised with
      # the content of a string.
      #
      # @param [String] str A Ruby string with data to copy to the +Malloc+
      # object.
      # @return [Memory] The new +Memory+ object initialised with the data.
      def import( str )
        retval = alloc str.bytesize
        retval.import str
        retval
      end

    end

    def initialize( ptr )
      super ptr
    end

    def load( typecode )
      typecode.unpack export( typecode.bytesize )
    end

    def store( typecode, value )
      import typecode.pack( value )
    end

    def import( data )
      @data.write data
    end

    def export( bytesize )
      @data.read bytesize
    end

    def +( offset )
      Memory.new @data + offset
    end

  end

end
