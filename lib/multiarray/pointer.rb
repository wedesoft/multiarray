module Hornetseye

  class Pointer_ < Node

    class << self

      attr_accessor :target

      def inspect
        "*(#{target.inspect})"
      end

      def descriptor( hash )
        "*(#{target.to_s})"
      end

      def default
        target.memory.new target.storage_size
      end

      def ==( other )
        other.is_a? Class and other < Pointer_ and
          target == other.target
      end

      def hash
        [ :Pointer_, target ].hash
      end

      def eql?
        self == other
      end

      def typecode
        target
      end

      def array_type
        target
      end

      def pointer_type
        self
      end

    end

    def initialize( value = self.class.default )
      @value = value
    end

    def strip
      variable = Variable.new self.class
      return [ variable ], [ self ], variable
    end

    def inspect
      "#{self.class.inspect}(#{@value.inspect})"
    end

    def descriptor( hash )
      "#{self.class.to_s}(#{@value.to_s})"
    end

    def store( value )
      result = value.demand
      self.class.target.new( result.get ).write @value
      result
    end

    def demand
      self.class.target.fetch( @value ).demand
    end

    def lookup( value, stride )
      if value.is_a? Variable
        Lookup.new self, value, stride
      else
        self.class.new @value + ( stride.get *
                                  self.class.target.storage_size ) * value.get
      end
    end

  end

  def Pointer( target )
    p = Class.new Pointer_
    p.target = target
    p
  end

  module_function :Pointer

end
