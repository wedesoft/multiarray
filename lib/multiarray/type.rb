module MultiArray

  class Type

    class << self

      def alloc
        memory.alloc bytesize
      end

      def typecode
        self
      end

    end

    def bytesize
      self.class.bytesize
    end

    def typecode
      self.class.typecode
    end

    def initialize( value = nil )
      @memory = self.class.alloc
      set value unless value.nil?
    end

    def inspect
      "#{self.class.inspect}(#{to_s})"
    end

    def to_s
      get.to_s
    end

    def set( value = typecode.default )
      @memory.store self.class, value
      value
    end

    def get
      @memory.load self.class
    end

  end

  Type.class_eval { include ScalarOperation }

end
