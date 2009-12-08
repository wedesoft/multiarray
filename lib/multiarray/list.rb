module MultiArray

  class List < Storage

    class << self

      def alloc( size )
        List.new Array.new( size )
      end

      def import( arr )
        List.new arr
      end

    end

    def initialize( arr )
      super arr
      @offset = 0
    end

    def load( typecode )
      @data[ @offset ]
    end

    def store( typecode, value )
      @data[ @offset ] = value
    end

    def import( data )
      @data[ @offset ... @offset + data.size ] = data
    end

    def export( size )
      @data[ @offset ... @offset + size ]
    end


  end

end
