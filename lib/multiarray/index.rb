module Hornetseye

  class INDEX_ < Element

    class << self

      attr_accessor :size

      def inspect
        "INDEX(#{size.inspect})"
      end

      def descriptor( hash )
        "INDEX(#{size.descriptor( hash )})"
      end

      def array_type
        INT
      end

      def strip
        var = Variable.new INT
        return [ var ], [ size ], INDEX( var )
      end

      def subst( hash )
        INDEX size.subst( hash )
      end

      def variables
        size.variables
      end

    end

    def initialize
      raise "#{self.class.inspect} must not be instantiated"
    end

  end

  def INDEX( size )
    retval = Class.new INDEX_
    size = INT.new( size ) unless size.is_a? Node
    retval.size = size
    retval
  end

  module_function :INDEX

end
