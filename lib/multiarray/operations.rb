module Hornetseye

  module Operations

    def define_unary_op( op, conversion = :contiguous )
      define_method( op ) do
        if dimension == 0 and variables.empty?
          target = typecode.send conversion
          target.new demand.get.send( op )
        else
          Unary( op ).new( self ).force
        end
      end
    end

    module_function :define_unary_op

    def define_binary_op( op, coercion = :coercion )
      define_method( op ) do |other|
        other = Node.match( other, typecode ).new other unless other.is_a? Node
        if dimension == 0 and variables.empty? and
            other.dimension == 0 and other.variables.empty?
          target = array_type.send coercion, other.array_type
          target.new demand.get.send( op, other.demand.get )
        else
          Binary( op ).new( self, other ).force
        end
      end
    end

    module_function :define_binary_op

    define_unary_op  :zero?   , :bool
    define_unary_op  :not
    define_unary_op  :-@
    define_binary_op :+
    define_binary_op :-
    define_binary_op :*
    define_binary_op :/
    define_binary_op :%
    define_binary_op :and
    define_binary_op :or
    define_binary_op :eq, :bool_binary
    define_binary_op :ne, :bool_binary

  end

  class Node

    include Operations

  end

end
