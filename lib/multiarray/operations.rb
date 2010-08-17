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
          target.new simplify.get.send( op )
        else
          Hornetseye::UnaryOp( op, conversion ).new( self ).force
        end
      end
    end

    module_function :define_unary_op

    def define_binary_op( op, coercion = :coercion )
      define_method( op ) do |other|
        unless other.is_a? Node
          other = Node.match( other, typecode ).new other
        end
        if dimension == 0 and variables.empty? and
            other.dimension == 0 and other.variables.empty?
          target = array_type.send coercion, other.array_type
          target.new simplify.get.send( op, other.simplify.get )
        else
          Hornetseye::BinaryOp( op, coercion ).new( self, other ).force
        end
      end
    end

    module_function :define_binary_op

    define_unary_op :zero?, :bool
    define_unary_op :nonzero?, :bool
    define_unary_op :not, :bool
    define_unary_op :~
    define_unary_op :-@
    define_unary_op :floor
    define_unary_op :ceil
    define_unary_op :round
    define_binary_op :+
    define_binary_op :-
    define_binary_op :*
    define_binary_op :**, :largeint
    define_binary_op :/
    define_binary_op :%
    define_binary_op :and, :bool_binary
    define_binary_op :or, :bool_binary
    define_binary_op :&
    define_binary_op :|
    define_binary_op :^
    define_binary_op :<<
    define_binary_op :>>
    define_binary_op :eq, :bool_binary
    define_binary_op :ne, :bool_binary
    define_binary_op :<=, :bool_binary
    define_binary_op :<, :bool_binary
    define_binary_op :>=, :bool_binary
    define_binary_op :>, :bool_binary
    define_binary_op :<=>, :byteval
    define_binary_op :minor
    define_binary_op :major

    def +@
      self
    end

    def conditional( a, b )
      unless a.is_a? Node
        a = Node.match( a, b.is_a?( Node ) ? b : nil ).new a
      end
      unless b.is_a? Node
        b = Node.match( b, a.is_a?( Node ) ? a : nil ).new b
      end
      if dimension == 0 and variables.empty? and
        a.dimension == 0 and a.variables.empty? and
        b.dimension == 0 and b.variables.empty?
        target = a.array_type.coercion b.array_type
        target = Hornetseye::MultiArray( target.typecode, *shape ).coercion target
        target.new simplify.get.conditional( a.get, b.get )
      else
        Hornetseye::Conditional.new( self, a, b ).force
      end
    end

    # Lazy transpose of array
    #
    # Lazily compute transpose by swapping indices according to the specified
    # order.
    #
    # @param [Array<Integer>] order New order of indices.
    #
    # @return [Node] Returns the transposed array.
    def transpose( *order )
      term = self
      variables = shape.reverse.collect do |i|
        var = Variable.new Hornetseye::INDEX( i )
        term = term.element var
        var
      end.reverse
      order.collect { |o| variables[o] }.
        inject( term ) { |retval,var| Lambda.new var, retval }
    end

    def roll( n = 1 )
      if n < 0
        unroll -n
      else
        order = ( 0 ... dimension ).to_a
        n.times { order = order[ 1 .. -1 ] + [ order.first ] }
        transpose *order
      end
    end

    def unroll( n = 1 )
      if n < 0
        roll -n
      else
        order = ( 0 ... dimension ).to_a
        n.times { order = [ order.last ] + order[ 0 ... -1 ] }
        transpose *order
      end
    end

    def inject( initial = nil, options = {} )
      unless initial.nil?
        initial = Node.match( initial ).new initial unless initial.is_a? Node
        initial_typecode = initial.typecode
      else
        initial_typecode = typecode
      end
      var1 = options[ :var1 ] || Variable.new( initial_typecode )
      var2 = options[ :var2 ] || Variable.new( typecode )
      block = options[ :block ] || yield( var1, var2 )
      if dimension == 0
        if initial
          block.subst( var1 => initial, var2 => self ).simplify
        else
          demand
        end
      else
        index = Variable.new Hornetseye::INDEX( nil )
        value = element( index ).
          inject nil, :block => block, :var1 => var1, :var2 => var2
        Inject.new( value, index, initial, block, var1, var2 ).force
      end
    end

    # Equality operator
    #
    # @return [FalseClass,TrueClass] Returns result of comparison.
    def eq_with_multiarray( other )
      if other.is_a? Node
        if variables.empty?
          if other.array_type == array_type
            Hornetseye::eager { eq( other ).inject( true ) { |a,b| a.and b } }
          else
            false
          end
        else
          eq_without_multiarray other
        end
      else
        false
      end
    end

    alias_method_chain :==, :multiarray, :eq

    def min
      inject { |a,b| a.minor b }
    end

    def max
      inject { |a,b| a.major b }
    end

    # Apply accumulative operation over elements diagonally
    #
    # This method is used internally to implement convolutions.
    #
    # @param [Object,Node] initial Initial value.
    # @option options [Variable] :var1 First variable defining operation.
    # @option options [Variable] :var2 Second variable defining operation.
    # @option options [Variable] :block (yield( var1, var2 )) The operation to
    # apply diagonally.
    # @yield Optional operation to apply diagonally.
    #
    # @return [Node] Result of operation.
    #
    # @see #convolve
    #
    # @private
    def diagonal( initial = nil, options = {} )
      if dimension == 0
        demand
      else
        if initial
          unless initial.is_a? Node
            initial = Node.match( initial ).new initial
          end
          initial_typecode = initial.typecode
        else
          initial_typecode = typecode
        end
        index0 = Variable.new Hornetseye::INDEX( nil )
        index1 = Variable.new Hornetseye::INDEX( nil )
        index2 = Variable.new Hornetseye::INDEX( nil )
        var1 = options[ :var1 ] || Variable.new( initial_typecode )
        var2 = options[ :var2 ] || Variable.new( typecode )
        block = options[ :block ] || yield( var1, var2 )
        value = element( index1 ).element( index2 ).
          diagonal initial, :block => block, :var1 => var1, :var2 => var2
        term = Diagonal.new( value, index0, index1, index2, initial,
                             block, var1, var2 )
        index0.size[] ||= index1.size[]
        Lambda.new( index0, term ).force
      end
    end

    # Compute product table from two arrays
    #
    # Used internally to implement convolutions.
    #
    # @param [Node] filter Filter to form product table with.
    #
    # @return [Node] Result of operation.
    #
    # @see #convolve
    #
    # @private
    def product( filter )
      if dimension == 0
        self * filter
      else
        Hornetseye::lazy { |i,j| self[j].product filter[i] }
      end
    end

    # Convolution with other array of same dimension
    #
    # @param [Node] filter Filter to convolve with.
    #
    # @return [Node] Result of convolution.
    def convolve( filter )
      product( filter ).diagonal { |s,x| s + x }
    end

  end

  class Node

    include Operations

  end

end
