module MultiArray

  class Memory < Storage

    class << self

      def alloc( bytesize )
        Memory.new Malloc.new( bytesize )
      end

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
