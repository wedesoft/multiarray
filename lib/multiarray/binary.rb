module Hornetseye

  class Binary_ < Node

    class << self

      attr_accessor :operation
      attr_accessor :coercion

      def inspect
        operation.to_s
      end

      def descriptor( hash )
        operation.to_s
      end

    end

    def initialize( value1, value2 )
      @value1, @value2 = value1, value2
    end

    def descriptor( hash )
      "(#{@value1.descriptor( hash )}).#{self.class.descriptor( hash )}(#{@value2.descriptor( hash )})"
    end

    def array_type
      @value1.array_type.send self.class.coercion, @value2.array_type
    end

    def subst( hash )
      self.class.new @value1.subst( hash ), @value2.subst( hash )
    end

    def variables
      @value1.variables + @value2.variables
    end

    def strip
      vars1, values1, term1 = @value1.strip
      vars2, values2, term2 = @value2.strip
      return vars1 + vars2, values1 + values2, self.class.new( term1, term2 )
    end

    def demand
      @value1.send self.class.operation, @value2
    end

    def element( i )
      element1 = @value1.dimension == 0 ? @value1 : @value1.element( i )
      element2 = @value2.dimension == 0 ? @value2 : @value2.element( i )
      element1.send self.class.operation, element2
    end

  end

  def Binary( operation, coercion = :coercion )
    retval = Class.new Binary_
    retval.operation = operation
    retval.coercion = coercion
    retval
  end

  module_function :Binary

end
