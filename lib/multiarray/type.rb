module Hornetseye

  class Type

    class << self

      def alloc
        memory.alloc bytesize
      end

      def typecode
        self
      end

      def basetype
        self
      end

      def shape
        []
      end

      def size
        shape.inject( 1 ) { |a,b| a * b }
      end

    end

    attr_accessor :memory

    def bytesize
      self.class.bytesize
    end

    def typecode
      self.class.typecode
    end

    def basetype
      self.class.basetype
    end

    def shape
      self.class.shape
    end

    def size
      self.class.size
    end

    def initialize( *args )
      options = args.last.is_a?( Hash ) ? args.pop : {}
      raise ArgumentError.new( 'Too many arguments' ) unless args.size <= 1
      value = args.empty? ? nil : args.first
      @memory = options[ :memory ] ? options[ :memory ] : self.class.alloc
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

    def sel
      self
    end

  end

  Type.class_eval { include TypeOperation }

end
