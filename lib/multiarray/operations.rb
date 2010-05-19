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

    define_unary_op :-@

  end

  class Node

    include Operations

  end

end
