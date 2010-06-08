# multiarray - Lazy multi-dimensional arrays for Ruby
# Copyright (C) 2010 Jan Wedekind
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Namespace of Hornetseye computer vision library
module Hornetseye

  module Operations

    def define_unary_op( op, conversion = :contiguous )
      define_method( op ) do
        if dimension == 0 and variables.empty?
          target = typecode.send conversion
          target.new demand.get.send( op )
        else
          Hornetseye::Unary( op, conversion ).new( self ).force
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
          Hornetseye::Binary( op, coercion ).new( self, other ).force
        end
      end
    end

    module_function :define_binary_op

    define_unary_op  :zero?   , :bool
    define_unary_op  :nonzero?, :bool
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
