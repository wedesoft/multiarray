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

  # Module providing the operations to manipulate array expressions
  module Operations

    # Meta-programming method to define a unary operation
    #
    # @param [Symbol,String] op Name of unary operation.
    # @param [Symbol,String] conversion Name of method for type conversion.
    #
    # @return [Proc] The new method.
    #
    # @private
    def define_unary_op( op, conversion = :contiguous )
      define_method( op ) do
        if dimension == 0 and variables.empty?
          target = typecode.send conversion
          target.new simplify.get.send( op )
        else
          Hornetseye::ElementWise( lambda { |x| x.send op }, op,
                                   lambda { |t| t.send conversion } ).
            new( self ).force
        end
      end
    end

    module_function :define_unary_op

    # Meta-programming method to define a binary operation
    #
    # @param [Symbol,String] op Name of binary operation.
    # @param [Symbol,String] conversion Name of method for type conversion.
    #
    # @return [Proc] The new method.
    #
    # @private
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
          Hornetseye::ElementWise( lambda { |x,y| x.send op, y }, op,
                                   lambda { |t,u| t.send coercion, u } ).
            new( self, other ).force
        end
      end
    end

    module_function :define_binary_op

    define_unary_op :zero?, :bool
    define_unary_op :nonzero?, :bool
    define_unary_op :not, :bool
    define_unary_op :~
    define_unary_op :-@
    define_unary_op :conj
    define_unary_op :abs, :scalar
    define_unary_op :arg, :float_scalar
    define_unary_op :floor
    define_unary_op :ceil
    define_unary_op :round
    define_binary_op :+
    define_binary_op :-
    define_binary_op :*
    define_binary_op :**, :coercion_maxint
    define_binary_op :/
    define_binary_op :%
    define_binary_op :and, :coercion_bool
    define_binary_op :or, :coercion_bool
    define_binary_op :&
    define_binary_op :|
    define_binary_op :^
    define_binary_op :<<
    define_binary_op :>>
    define_binary_op :eq, :coercion_bool
    define_binary_op :ne, :coercion_bool
    define_binary_op :<=, :coercion_bool
    define_binary_op :<, :coercion_bool
    define_binary_op :>=, :coercion_bool
    define_binary_op :>, :coercion_bool
    define_binary_op :<=>, :coercion_byte
    define_binary_op :minor
    define_binary_op :major

    # This operation has no effect
    #
    # @return [Node] Returns +self+.
    #
    # @private
    def +@
      self
    end

    # Convert array elements to different element type
    #
    # @param [Class] dest Element type to convert to.
    #
    # @return [Node] Array based on the different element type.
    def to_type( dest )
      if dimension == 0 and variables.empty?
        target = typecode.to_type dest
        target.new simplify.get
      else
        key = "to_#{dest.to_s.downcase}"
        Hornetseye::ElementWise( lambda { |x| x.to_type dest }, key,
                                 lambda { |t| t.to_type dest } ).new( self ).force
      end
    end

    # Convert RGB array to scalar array
    #
    # This operation is a special case handling colour to greyscale conversion.
    #
    # @param [Class] dest Element type to convert to.
    #
    # @return [Node] Array based on the different element type.
    def to_type_with_rgb( dest )
      if typecode < RGB_
        if dest < FLOAT_
          lazy { r * 0.299 + g * 0.587 + b * 0.114 }.to_type dest
        elsif dest < INT_
          lazy { ( r * 0.299 + g * 0.587 + b * 0.114 ).round }.to_type dest
        else
          to_type_without_rgb dest
        end
      else
        to_type_without_rgb dest
      end
    end

    alias_method_chain :to_type, :rgb

    # Element-wise conditional selection of values
    #
    # @param [Node] a First array of values.
    # @param [Node] b Second array of values.
    #
    # @return [Node] Array with selected values.
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
        target = array_type.cond a.array_type, b.array_type
        target.new simplify.get.conditional( a.simplify.get, b.simplify.get )
      else
        Hornetseye::ElementWise( lambda { |x,y,z| x.conditional y, z }, :conditional,
                                 lambda { |t,u,v| t.cond u, v } ).
          new( self, a, b ).force
      end
    end

    # Element-wise comparison of values
    #
    # @param [Node] other Array with values to compare with.
    #
    # @return [Node] Array with results.
    def <=>( other )
      Hornetseye::lazy do
        ( self < other ).conditional -1, ( self > other ).conditional( 1, 0 )
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

    # Cycle indices of array
    #
    # @param [Integer] n Number of times to cycle indices of array.
    #
    # @return [Node] Resulting array expression with different order of indices.
    def roll( n = 1 )
      if n < 0
        unroll -n
      else
        order = ( 0 ... dimension ).to_a
        n.times { order = order[ 1 .. -1 ] + [ order.first ] }
        transpose *order
      end
    end

    # Reverse-cycle indices of array
    #
    # @param [Integer] n Number of times to cycle back indices of array.
    #
    # @return [Node] Resulting array expression with different order of indices.
    def unroll( n = 1 )
      if n < 0
        roll -n
      else
        order = ( 0 ... dimension ).to_a
        n.times { order = [ order.last ] + order[ 0 ... -1 ] }
        transpose *order
      end
    end

    # Perform element-wise operation on array
    #
    # @param [Proc] action Operation(s) to perform on elements.
    #
    # @return [Node] The resulting array.
    def collect( &action )
      var = Variable.new typecode
      block = action.call var
      conversion = lambda { |t| t.to_type action.call( Variable.new( t.typecode ) ) }
      Hornetseye::ElementWise( action, block.to_s, conversion ).new( self ).force
    end

    alias_method :map, :collect

    # Perform cummulative operation on array
    #
    # @param [Object] initial Initial value for cummulative operation.
    # @option options [Variable] :var1 First variable defining operation.
    # @option options [Variable] :var1 Second variable defining operation.
    # @option options [Variable] :block (yield( var1, var2 )) The operation to
    #         apply.
    #
    # @return [Object] Result of injection.
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
        value = element( index ).inject nil, :block => block,
                                        :var1 => var1, :var2 => var2
        value = typecode.new value unless value.is_a? Node
        Inject.new( value, index, initial, block, var1, var2 ).force
      end
    end

    # Equality operator
    #
    # @return [Boolean] Returns result of comparison.
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

    # Find minimum value of array
    #
    # @return [Object] Minimum value of array.
    def min
      inject { |a,b| a.minor b }
    end

    # Find maximum value of array
    #
    # @return [Object] Maximum value of array.
    def max
      inject { |a,b| a.major b }
    end

    # Compute sum of array
    #
    # @return [Object] Sum of array.
    def sum
      inject { |a,b| a + b }
    end

    # Find range of values of array
    #
    # @return [Object] Range of values of array.
    def range
      min .. max
    end

    # Normalise values of array
    #
    # @param [Range] range Target range of normalisation.
    #
    # @return [Node] Array with normalised values.
    def normalise( range = 0 .. 0xFF )
      if range.exclude_end?
        raise "Normalisation does not support ranges with end value " +
              "excluded (such as #{range})"
      end
      lower, upper = min, max
      if lower.is_a? RGB or upper.is_a? RGB
        current = [ lower.r, lower.g, lower.b ].min ..
                  [ upper.r, upper.g, upper.b ].max
      else
        current = min .. max
      end
      if current.last != current.first
        factor =
          ( range.last - range.first ).to_f / ( current.last - current.first )
        self * factor + ( range.first - current.first * factor )
      else
        self + ( range.first - current.first )
      end
    end

    # Fill array with a value
    #
    # @param [Object] value Value to fill array with.
    #
    # @return [Node] Return +self+.
    def fill!( value = typecode.default )
      self[] = value
      self
    end

    # Apply accumulative operation over elements diagonally
    #
    # This method is used internally to implement convolutions.
    #
    # @param [Object,Node] initial Initial value.
    # @option options [Variable] :var1 First variable defining operation.
    # @option options [Variable] :var2 Second variable defining operation.
    # @option options [Variable] :block (yield( var1, var2 )) The operation to
    #         apply diagonally.
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
      filter = Node.match( filter, typecode ).new filter unless filter.is_a? Node
      if dimension != filter.dimension
        raise "Filter has #{filter.dimension} dimension(s) but should " +
              "have #{dimension}"
      end
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
      filter = Node.match( filter, typecode ).new filter unless filter.is_a? Node
      product( filter ).diagonal { |s,x| s + x }
    end

    def histogram( *ret_shape )
      options = ret_shape.last.is_a?( Hash ) ? ret_shape.pop : {}
      options = { :target => UINT, :safe => true }.merge options
      if options[ :safe ]
        if shape.first != 1 and ret_shape.size == 1
          right = Hornetseye::lazy( 1 ) { self }.unroll
        else
          if shape.first != ret_shape.size
            raise "First dimension of array (#{shape.first}) differs from number of " +
                  "dimensions of histogram (#{ret_shape.size})"
          end
          right = self
        end
      else
        right = self
      end
      if options[ :safe ]
        for i in 0 ... right.shape.first
          range = right.roll[ i ].range
          if range.begin < 0
            raise "#{i+1}th dimension of index must be in 0 ... #{ret_shape[i]} " +
                  "(but was #{range.begin})"
          end
          if range.end >= ret_shape[ i ]
            raise "#{i+1}th dimension of index must be in 0 ... #{ret_shape[i]} " +
                  "(but was #{range.end})"
          end
        end
      end
      left = MultiArray.new options[ :target ], *ret_shape
      left[] = 0
      block = Histogram.new left, right
      if block.compilable?
        GCCFunction.run block
      else
        block.demand
      end
      left
    end

    #def histogram_with_composite( *ret_shape )
    #  decompose.histogram_without_composite *ret_shape
    #end

    #alias_method_chain :histogram, :composite

    def lut( table, options = {} )
      options = { :safe => true }.merge options
      if options[ :safe ]
        if shape.first != 1 and table.dimension == 1
          source = Hornetseye::lazy( 1 ) { |i| self }.unroll
        else
          if shape.first > table.dimension
            raise "First dimension of array (#{shape.first}) is greater than the " +
                  " number of dimensions of LUT (#{table.dimension})"
          end
          source = self
        end
      else
        source = self
      end
      if options[ :safe ]
        for i in 0 ... source.shape.first
          range = source.roll[ i ].range
          if range.begin < 0
            raise "#{i+1}th dimension of index must be in 0 ... #{table.shape[i]} " +
                  "(but was #{range.begin})"
          end
          offset = table.dimension - source.shape.first
          if range.end >= table.shape[ i + offset ]
            raise "#{i+1}th dimension of index must be in 0 ... " +
                  "#{table.shape[ i + offset ]} (but was #{range.end})"
          end
        end
      end
      if source.dimension <= 1 and variables.empty?
        result = table
        ( table.dimension - 1 ).downto( 0 ) do |i|
          result = result.element source.element( INT.new( i ) ).demand
        end
        result
      else
        Lut.new( source, table, options[ :n ] ).force
      end
    end

    #def lut_with_composite( table, options = {} )
    #  decompose.lut_without_composite table, options
    #end

    #alias_method_chain :lut, :composite

    def integral
      left = pointer_type.new
      block = Integral.new left, self
      if block.compilable?
        GCCFunction.run block
      else
        block.demand
      end
      left
    end

  end

  class Node

    include Operations

  end

end
