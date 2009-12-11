module Hornetseye

  # @abstract
  class Type

    class << self

      # @private
      def alloc
        memory.alloc bytesize
      end

      # @private
      def wrap( memory )
        new :memory => memory
      end

      def typecode
        self
      end

      # @private
      def basetype
        self
      end

      def empty?
        size == 0
      end

      def shape
        []
      end

      def size
        shape.inject( 1 ) { |a,b| a * b }
      end

    end

    # @private
    attr_accessor :memory

    def bytesize
      self.class.bytesize
    end

    def typecode
      self.class.typecode
    end

    # @private
    def basetype
      self.class.basetype
    end
    
    def empty?
      self.class.empty?
    end

    def shape
      self.class.shape
    end

    def size
      self.class.size
    end

    # @private
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

    def to_a
      get.to_a
    end

    def at( *indices )
      sel( *indices ).get
    end

    alias_method :[], :at

    def assign( *args )
      sel( *args[ 0 ... -1 ] ).set args.last
    end

    alias_method :[]=, :assign

  end

end
