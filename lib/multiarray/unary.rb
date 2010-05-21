module Hornetseye

  class Unary_ < Node

    class << self

      attr_accessor :operation
      attr_accessor :conversion

      def inspect
        operation.to_s
      end

      def descriptor( hash )
        operation.to_s
      end

    end

    def initialize( value )
      @value = value
    end

    def descriptor( hash )
      "(#{@value.descriptor( hash )}).#{self.class.descriptor( hash )}"
    end

    def array_type
      @value.array_type.send self.class.conversion
    end

    def subst( hash )
      self.class.new @value.subst( hash )
    end

    def variables
      @value.variables
    end

    def strip
      vars, values, term = @value.strip
      return vars, values, self.class.new( term )
    end

    def demand
      @value.send self.class.operation
    end

    def element( i )
      @value.element( i ).send self.class.operation
    end

  end

  def Unary( operation, conversion = :contiguous )
    retval = Class.new Unary_
    retval.operation = operation
    retval.conversion = conversion
    retval
  end

  module_function :Unary

end
