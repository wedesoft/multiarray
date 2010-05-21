module Hornetseye

  class List

    def initialize( n, options = {} )
      @array = options[ :array ] || [ nil ] * n
      @offset = options[ :offset ] || 0
    end

    def inspect
      "List(#{@array.size - @offset})"
    end

    def to_s
      "List(#{@array[ @offset .. -1 ]})"
    end

    def +( offset )
      List.new 0, :array => @array, :offset => @offset + offset
    end

    def load( typecode )
      @array[ @offset ]
    end

    def save( value )
      @array[ @offset ] = value.get
    end

  end

end
