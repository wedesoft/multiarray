module Hornetseye

  module Operations

    def define_unary_op( op )
      define_method( op ) do
        if dimension == 0 and variables.empty?
          typecode.new demand.get.send( op )
        else
          Unary( op ).new( self ).force
        end
      end
    end

    module_function :define_unary_op

    def define_binary_op( op )
      define_method( op ) do |other|
        other = Node.match( other, typecode ).new other unless other.is_a? Node
        if dimension == 0 and variables.empty? and
            other.dimension == 0 and other.variables.empty?
          target = array_type.coercion other.array_type
          target.new demand.get.send( op, other.demand.get )
        else
          Binary( op ).new( self, other ).force
        end
      end
    end

    module_function :define_binary_op

    define_unary_op  :-@
    define_binary_op :+
    define_binary_op :-
    define_binary_op :*

  end

  class Node

    include Operations

  end

end
