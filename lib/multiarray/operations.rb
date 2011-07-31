# multiarray - Lazy multi-dimensional arrays for Ruby
# Copyright (C) 2010, 2011, 2011 Jan Wedekind
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

  # Base class for representing native datatypes and operations (terms)
  class Node

    class << self

      # Meta-programming method to define a unary operation
      #
      # @param [Symbol,String] op Name of unary operation.
      # @param [Symbol,String] conversion Name of method for type conversion.
      #
      # @return [Proc] The new method.
      #
      # @private
      def define_unary_op(op, conversion = :identity)
        Node.class_eval do
          define_method op do
            if dimension == 0 and variables.empty?
              target = typecode.send conversion
              target.new simplify.get.send(op)
            else
              Hornetseye::ElementWise(proc { |x| x.send op }, op,
                                      proc { |t| t.send conversion }).
                new(self).force
            end
          end
        end
      end

      # Meta-programming method to define a binary operation
      #
      # @param [Symbol,String] op Name of binary operation.
      # @param [Symbol,String] conversion Name of method for type conversion.
      #
      # @return [Proc] The new method.
      #
      # @private
      def define_binary_op(op, coercion = :coercion)
        define_method op do |other|
          other = Node.match(other, typecode).new other unless other.matched?
          if dimension == 0 and variables.empty? and
              other.dimension == 0 and other.variables.empty?
            target = typecode.send coercion, other.typecode
            target.new simplify.get.send(op, other.simplify.get)
          else
            Hornetseye::ElementWise(proc { |x,y| x.send op, y }, op,
                                    proc { |t,u| t.send coercion, u } ).
              new(self, other).force
          end
        end
      end

    end
  
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
    define_binary_op :fmod
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

    # Modulo operation for floating point numbers
    #
    # This operation takes account of the problem that '%' does not work with
    # floating-point numbers in C.
    #
    # @return [Node] Array with result of operation.
    def fmod_with_float( other )
      other = Node.match( other, typecode ).new other unless other.matched?
      if typecode < FLOAT_ or other.typecode < FLOAT_
        fmod other
      else
        fmod_without_float other
      end
    end

    alias_method_chain :%, :float, :fmod

    # Convert array elements to different element type
    #
    # @param [Class] dest Element type to convert to.
    #
    # @return [Node] Array based on the different element type.
    def to_type(dest)
      if dimension == 0 and variables.empty?
        target = typecode.to_type dest
        target.new(simplify.get).simplify
      else
        key = "to_#{dest.to_s.downcase}"
        Hornetseye::ElementWise( proc { |x| x.to_type dest }, key,
                                 proc { |t| t.to_type dest } ).new(self).force
      end
    end

    # Convert RGB array to scalar array
    #
    # This operation is a special case handling colour to greyscale conversion.
    #
    # @param [Class] dest Element type to convert to.
    #
    # @return [Node] Array based on the different element type.
    def to_type_with_rgb(dest)
      if typecode < RGB_
        if dest < FLOAT_
          lazy { r * 0.299 + g * 0.587 + b * 0.114 }.to_type dest
        elsif dest < INT_
          lazy { (r * 0.299 + g * 0.587 + b * 0.114).round }.to_type dest
        else
          to_type_without_rgb dest
        end
      else
        to_type_without_rgb dest
      end
    end

    alias_method_chain :to_type, :rgb

    # Skip type conversion if it has no effect
    #
    # This operation is a special case handling type conversions to the same type.
    #
    # @param [Class] dest Element type to convert to.
    #
    # @return [Node] Array based on the different element type.
    def to_type_with_identity( dest )
      if dest == typecode
        self
      else
        to_type_without_identity dest
      end
    end

    alias_method_chain :to_type, :identity

    # Get array with same elements but different shape
    #
    # The method returns an array with the same elements but with a different shape.
    # The desired shape must have the same number of elements.
    #
    # @param [Array<Integer>] ret_shape Desired shape of return value
    #
    # @return [Node] Array with desired shape.
    def reshape(*ret_shape)
      target_size = ret_shape.inject 1, :*
      if target_size != size
        raise "Target is of size #{target_size} but should be of size #{size}"
      end
      Hornetseye::MultiArray(typecode, ret_shape.size).
        new *(ret_shape + [:memory => memorise.memory])
    end

    # Element-wise conditional selection of values
    #
    # @param [Node] a First array of values.
    # @param [Node] b Second array of values.
    #
    # @return [Node] Array with selected values.
    def conditional(a, b)
      a = Node.match(a, b.matched? ? b : nil).new a unless a.matched?
      b = Node.match(b, a.matched? ? a : nil).new b unless b.matched?
      if dimension == 0 and variables.empty? and
        a.dimension == 0 and a.variables.empty? and
        b.dimension == 0 and b.variables.empty?
        target = typecode.cond a.typecode, b.typecode
        target.new simplify.get.conditional(proc { a.simplify.get },
                                            proc { b.simplify.get })
      else
        Hornetseye::ElementWise(proc { |x,y,z| x.conditional y, z }, :conditional,
                                proc { |t,u,v| t.cond u, v }).
          new(self, a, b).force
      end
    end

    # Generate code for memory allocation
    #
    # @return [GCCValue] C value referring to result.
    #
    # @private
    def malloc
      get.malloc 
    end

    # Conditional operation
    #
    # @param [Proc] action Action to perform if condition is +true+.
    #
    # @return [Object] The return value should be ignored.
    def if( &action )
      simplify.get.if &action
    end

    # Conditional operation
    #
    # @param [Proc] action1 Action to perform if condition is +true+.
    # @param [Proc] action2 Action to perform if condition is +false+.
    #
    # @return [Object] The return value should be ignored.
    def if_else( action1, action2 )
      simplify.get.if_else action1, action2
    end

    # Element-wise comparison of values
    #
    # @param [Node] other Array with values to compare with.
    #
    # @return [Node] Array with results.
    def <=>(other)
      Hornetseye::lazy do
        (self < other).conditional -1, (self > other).conditional(1, 0)
      end.force
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
        inject(term) { |retval,var| Lambda.new var, retval }
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
    def collect(&action)
      var = Variable.new typecode
      block = action.call var
      conversion = proc { |t| t.to_type action.call(Variable.new(t.typecode)).typecode }
      Hornetseye::ElementWise( action, block.to_s, conversion ).new( self ).force
    end

    # Perform element-wise operation on array
    #
    # @param [Proc] action Operation(s) to perform on elements.
    #
    # @return [Node] The resulting array.
    alias_method :map, :collect

    # Perform cummulative operation on array
    #
    # @overload inject(initial = nil, options = {}, &action)
    #   @param [Object] initial Initial value for cummulative operation.
    #   @option options [Variable] :var1 First variable defining operation.
    #   @option options [Variable] :var1 Second variable defining operation.
    #   @option options [Variable] :block (action.call(var1, var2)) The operation to apply.
    #
    # @overload inject(initial = nil, symbol)
    #   @param [Object] initial Initial value for cummulative operation.
    #   @param [Symbol,String] symbol The operation to apply.
    #
    # @return [Object] Result of injection.
    def inject(*args, &action)
      options = args.last.is_a?(Hash) ? args.pop : {}
      unless action or options[:block]
        unless [1, 2].member? args.size
          raise "Inject expected 1 or 2 arguments but got #{args.size}" 
        end
        initial, symbol = args[-2], args[-1]
        action = proc { |a,b| a.send symbol, b }
      else
        raise "Inject expected 0 or 1 arguments but got #{args.size}" if args.size > 1
        initial = args.empty? ? nil : args.first
      end
      unless initial.nil?
        initial = Node.match( initial ).new initial unless initial.matched?
        initial_typecode = initial.typecode
      else
        initial_typecode = typecode
      end
      var1 = options[ :var1 ] || Variable.new( initial_typecode )
      var2 = options[ :var2 ] || Variable.new( typecode )
      block = options[ :block ] || action.call( var1, var2 )
      if dimension == 0
        if initial
          block.subst(var1 => initial, var2 => self).simplify
        else
          demand
        end
      else
        index = Variable.new Hornetseye::INDEX( nil )
        value = element( index ).inject nil, :block => block,
                                        :var1 => var1, :var2 => var2
        value = typecode.new value unless value.matched?
        if initial.nil? and index.size.get == 0
          raise "Array was empty and no initial value for injection was given"
        end
        Inject.new( value, index, initial, block, var1, var2 ).force
      end
    end

    def each( &action )
      if dimension > 0
        shape.last.times { |i| element( INT.new( i ) ).each &action }
      else
        action.call demand.get
      end
    end

    # Equality operator
    #
    # @return [Boolean] Returns result of comparison.
    def eq_with_multiarray(other)
      if other.matched?
        if variables.empty?
          if other.typecode == typecode and other.shape == shape
            Hornetseye::finalise { eq(other).inject true, :and }
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
    # @param [Object] initial Only consider values less than this value.
    #
    # @return [Object] Minimum value of array.
    def min( initial = nil )
      inject initial, :minor
    end

    # Find maximum value of array
    #
    # @param [Object] initial Only consider values greater than this value.
    #
    # @return [Object] Maximum value of array.
    def max( initial = nil )
      inject initial, :major
    end

    # Compute sum of array
    #
    # @return [Object] Sum of array.
    def sum
      Hornetseye::lazy { to_type typecode.maxint }.inject :+
    end

    # Compute average of array
    #
    # @return [Object] Mean of array.
    def mean
      sum / size
    end

    # Find range of values of array
    #
    # @return [Object] Range of values of array.
    def range( initial = nil )
      min( initial ? initial.min : nil ) .. max( initial ? initial.max : nil )
    end

    # Check values against boundaries
    #
    # @return [Node] Boolean array with result.
    def between?( a, b )
      Hornetseye::lazy { ( self >= a ).and self <= b }.force
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
        collect { |x| x * factor + ( range.first - current.first * factor ) }
      else
        self + ( range.first - current.first )
      end
    end

    # Clip values to specified range
    #
    # @param [Range] range Allowed range of values.
    #
    # @return [Node] Array with clipped values.
    def clip( range = 0 .. 0xFF )
      if range.exclude_end?
        raise "Clipping does not support ranges with end value " +
              "excluded (such as #{range})"
      end
      collect { |x| x.major( range.begin ).minor range.end }
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
          initial = Node.match( initial ).new initial unless initial.matched?
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
        index0.size = index1.size
        Lambda.new( index0, term ).force
      end
    end

    # Compute table from two arrays
    #
    # Used internally to implement convolutions and other operations.
    #
    # @param [Node] filter Filter to form table with.
    # @param [Proc] action Operation to make table for.
    #
    # @return [Node] Result of operation.
    #
    # @see #convolve
    #
    # @private
    def table( filter, &action )
      filter = Node.match( filter, typecode ).new filter unless filter.matched?
      if filter.dimension > dimension
        raise "Filter has #{filter.dimension} dimension(s) but should " +
              "not have more than #{dimension}"
      end
      filter = Hornetseye::lazy( 1 ) { filter } while filter.dimension < dimension
      if filter.dimension == 0
        action.call self, filter
      else
        Hornetseye::lazy { |i,j| self[j].table filter[i], &action }
      end
    end

    # Convolution with other array of same dimension
    #
    # @param [Node] filter Filter to convolve with.
    #
    # @return [Node] Result of convolution.
    def convolve( filter )
      filter = Node.match( filter, typecode ).new filter unless filter.matched?
      array = self
      (dimension - filter.dimension).times { array = array.roll }
      array.table(filter) { |a,b| a * b }.diagonal { |s,x| s + x }
    end

    # Erosion
    #
    # The erosion operation works on boolean as well as scalar values.
    #
    # @param [Integer] n Size of erosion operator.
    #
    # @return [Node] Result of operation.
    def erode( n = 3 )
      filter = Hornetseye::lazy( *( [ n ] * dimension ) ) { 0 }
      table( filter ) { |a,b| a }.diagonal { |m,x| m.minor x }
    end

    # Dilation
    #
    # The dilation operation works on boolean as well as scalar values.
    #
    # @param [Integer] n Size of dilation operator.
    #
    # @return [Node] Result of operation.
    def dilate( n = 3 )
      filter = Hornetseye::lazy( *( [ n ] * dimension ) ) { 0 }
      table( filter ) { |a,b| a }.diagonal { |m,x| m.major x }
    end

    # Sobel operator
    #
    # @param [Integer] direction Orientation of Sobel filter.
    #
    # @return [Node] Result of Sobel operator.
    def sobel( direction )
      ( dimension - 1 ).downto( 0 ).inject self do |retval,i|
        filter = i == direction ? Hornetseye::Sequence(SINT)[1, 0, -1] :
                                  Hornetseye::Sequence(SINT)[1, 2,  1]
        Hornetseye::lazy { retval.convolve filter }
      end.force
    end

    # Gaussian blur
    #
    # @param [Float] sigma Spread of Gauss bell.
    # @param [Float] max_error Error of approximated filter.
    #
    # @return [Node] Result of filter operation.
    def gauss_blur( sigma, max_error = 1.0 / 0x100 )
      filter_type = DFLOAT.align typecode
      filter = Sequence[ *Array.gauss_blur_filter( sigma, max_error / dimension ) ].
        to_type filter_type
      ( dimension - 1 ).downto( 0 ).inject self do |retval,i|
        retval.convolve filter
      end
    end

    # Gauss gradient
    #
    # @param [Float] sigma Spread of Gauss gradient.
    # @param [Integer] direction Orientation of Gauss gradient.
    # @param [Float] max_error Error of approximated filter.
    #
    # @return [Node] Result of filter operation.
    def gauss_gradient( sigma, direction, max_error = 1.0 / 0x100 )
      filter_type = DFLOAT.align typecode
      gradient =
        Sequence[ *Array.gauss_gradient_filter( sigma, max_error / dimension ) ].
        to_type filter_type
      blur =
        Sequence[ *Array.gauss_blur_filter( sigma, max_error / dimension ) ].
        to_type filter_type
      ( dimension - 1 ).downto( 0 ).inject self do |retval,i|
        filter = i == direction ? gradient : blur
        retval.convolve filter
      end.force
    end

    # Compute histogram of this array
    #
    # @overload histogram( *ret_shape, options = {} )
    #   @param [Array<Integer>] ret_shape Dimensions of resulting histogram.
    #   @option options [Node] :weight (UINT(1)) Weights for computing the histogram.
    #   @option options [Boolean] :safe (true) Do a boundary check before creating the
    #           histogram.
    #
    # @return [Node] The histogram.
    def histogram( *ret_shape )
      options = ret_shape.last.is_a?( Hash ) ? ret_shape.pop : {}
      options = { :weight => UINT.new( 1 ), :safe => true }.merge options
      unless options[:weight].matched?
        options[:weight] = Node.match(options[:weight]).maxint.new options[:weight]
      end
      if ( shape.first != 1 or dimension == 1 ) and ret_shape.size == 1
        [ self ].histogram *( ret_shape + [ options ] )
      else
        ( 0 ... shape.first ).collect { |i| unroll[i] }.
          histogram *( ret_shape + [ options ] )
      end
    end

    # Perform element-wise lookup
    #
    # @param [Node] table The lookup table (LUT).
    # @option options [Boolean] :safe (true) Do a boundary check before creating the
    #         element-wise lookup.
    #
    # @return [Node] The result of the lookup operation.
    def lut( table, options = {} )
      if ( shape.first != 1 or dimension == 1 ) and table.dimension == 1
        [ self ].lut table, options
      else
        ( 0 ... shape.first ).collect { |i| unroll[i] }.lut table, options
      end
    end

    # Warp an array
    #
    # @overload warp( *field, options = {} )
    #   @param [Array<Integer>] ret_shape Dimensions of resulting histogram.
    #   @option options [Object] :default (typecode.default) Default value for out of
    #           range warp vectors.
    #   @option options [Boolean] :safe (true) Apply clip to warp vectors.
    #
    # @return [Node] The result of the lookup operation.
    def warp( *field )
      options = field.last.is_a?( Hash ) ? field.pop : {}
      options = { :safe => true, :default => typecode.default }.merge options
      if options[ :safe ]
        if field.size > dimension
          raise "Number of arrays for warp (#{field.size}) is greater than the " +
                "number of dimensions of source (#{dimension})"
        end
        Hornetseye::lazy do
          ( 0 ... field.size ).
            collect { |i| ( field[i] >= 0 ).and( field[i] < shape[i] ) }.
            inject :and
        end.conditional Lut.new( *( field + [ self ] ) ), options[ :default ]
      else
        field.lut self, :safe => false
      end
    end

    # Compute integral image
    #
    # @return [Node] The integral image of this array.
    def integral
      left = allocate
      block = Integral.new left, self
      if block.compilable?
        GCCFunction.run block
      else
        block.demand
      end
      left
    end

    # Perform connected component labeling
    #
    # @option options [Object] :default (typecode.default) Value of background elements.
    # @option options [Class] :target (UINT) Typecode of labels.
    #
    # @return [Node] Array with labels of connected components.
    def components( options = {} )
      if shape.any? { |x| x <= 1 }
        raise "Every dimension must be greater than 1 (shape was #{shape})"
      end
      options = { :target => UINT, :default => typecode.default }.merge options
      target = options[ :target ]
      default = options[ :default ]
      default = typecode.new default unless default.matched?
      left = Hornetseye::MultiArray(target, dimension).new *shape
      labels = Sequence.new target, size; labels[0] = 0
      rank = Sequence.uint size; rank[0] = 0
      n = Hornetseye::Pointer( INT ).new; n.store INT.new( 0 )
      block = Components.new left, self, default, target.new(0),
                             labels, rank, n
      if block.compilable?
        Hornetseye::GCCFunction.run block
      else
        block.demand
      end
      labels = labels[0 .. n.demand.get]
      left.lut labels.lut(labels.histogram(labels.size, :weight => target.new(1)).
                          minor(1).integral - 1)
    end

    # Select values from array using a mask
    #
    # @param [Node] m Mask to apply to this array.
    #
    # @return [Node] The masked array.
    def mask( m )
      check_shape m
      left = MultiArray.new typecode, *( shape.first( dimension - m.dimension ) +
                                         [ m.size ] )
      index = Hornetseye::Pointer( INT ).new
      index.store INT.new( 0 )
      block = Mask.new left, self, m, index
      if block.compilable?
        GCCFunction.run block
      else
        block.demand
      end
      left[0 ... index[]].roll
    end

    # Distribute values in a new array using a mask
    #
    # @param [Node] m Mask for inverse masking operation.
    # @option options [Object] :default (typecode.default) Default value for elements
    #         where mask is +false+.
    # @option options [Boolean] :safe (true) Ensure that the size of this size is
    #         sufficient.
    #
    # @return [Node] The result of the inverse masking operation.
    def unmask( m, options = {} )
      options = { :safe => true, :default => typecode.default }.merge options
      default = options[:default]
      default = typecode.new default unless default.matched?
      m.check_shape default
      if options[ :safe ]
        if m.to_ubyte.sum > shape.last
          raise "#{m.to_ubyte.sum} value(s) of the mask are true but the last " +
            "dimension of the array for unmasking only has #{shape.last} value(s)"
        end
      end
      left = Hornetseye::MultiArray(typecode, dimension - 1 + m.dimension).
        coercion(default.typecode).new *(shape[1 .. -1] + m.shape)
      index = Hornetseye::Pointer(INT).new
      index.store INT.new(0)
      block = Unmask.new left, self, m, index, default
      if block.compilable?
        GCCFunction.run block
      else
        block.demand
      end
      left
    end

    # Mirror the array
    #
    # @param [Array<Integer>] dimensions The dimensions which should be flipped.
    #
    # @return [Node] The result of flipping the dimensions.
    def flip( *dimensions )
      field = ( 0 ... dimension ).collect do |i|
        if dimensions.member? i
          Hornetseye::lazy( *shape ) { |*args| shape[i] - 1 - args[i] }
        else
          Hornetseye::lazy( *shape ) { |*args| args[i] }
        end
      end
      warp *( field + [ :safe => false ] )
    end

    # Create array with shifted elements
    #
    # @param [Array<Integer>] offset Array with amount of shift for each dimension.
    #
    # @return [Node] The result of the shifting operation.
    def shift( *offset )
      if offset.size != dimension
        raise "#{offset.size} offset(s) were given but array has " +
              "#{dimension} dimension(s)"
      end
      retval = Hornetseye::MultiArray(typecode, dimension).new *shape
      target, source, open, close = [], [], [], []
      ( shape.size - 1 ).step( 0, -1 ) do |i|
        callcc do |pass|
          delta = offset[i] % shape[i]
          source[i] = 0 ... shape[i] - delta
          target[i] = delta ... shape[i]
          callcc do |c|
            open[i] = c
            pass.call
          end
          source[i] = shape[i] - delta ... shape[i]
          target[i] = 0 ... delta
          callcc do |c|
            open[i] = c
            pass.call
          end
          close[i].call
        end
      end
      retval[ *target ] = self[ *source ]
      for i in 0 ... shape.size
        callcc do |c|
          close[i] = c
          open[i].call
        end
      end
      retval
    end

    # Downsampling of arrays
    #
    # @overload downsample( *rate, options = {} )
    #   @param [Array<Integer>] rate The sampling rates for each dimension.
    #   @option options [Array<Integer>] :offset Sampling offsets for each dimension.
    #
    # @return [Node] The downsampled data.
    def downsample( *rate )
      options = rate.last.is_a?( Hash ) ? rate.pop : {}
      options = { :offset => rate.collect { |r| r - 1 } }.merge options
      offset = options[ :offset ]
      if rate.size != dimension
        raise "#{rate.size} sampling rate(s) given but array has " +
              "#{dimension} dimension(s)"
      end
      if offset.size != dimension
        raise "#{offset.size} sampling offset(s) given but array has " +
              "#{dimension} dimension(s)"
      end
      ret_shape = ( 0 ... dimension ).collect do |i|
        ( shape[i] + rate[i] - 1 - offset[i] ).div rate[i]
      end
      field = ( 0 ... dimension ).collect do |i|
        Hornetseye::lazy( *ret_shape ) { |*args| args[i] * rate[i] + offset[i] }
      end
      warp *( field + [ :safe => false ] )
    end

    #def scale( *ret_shape )
    #  field = ( 0 ... dimension ).collect do |i|
    #    Hornetseye::lazy( *ret_shape ) do |*args|
    #      ( args[i] * shape[i].to_f / ret_shape[i] ).to_type INT
    #    end
    #  end
    #  Hornetseye::lazy { to_type typecode.float }.integral
    #end

  end

end

# The +Array+ class is extended with a few methods
class Array

  # Compute histogram of this array
  #
  # @overload histogram( *ret_shape, options = {} )
  #   @param [Array<Integer>] ret_shape Dimensions of resulting histogram.
  #   @option options [Node] :weight (Hornetseye::UINT(1)) Weights for computing the
  #           histogram.
  #   @option options [Boolean] :safe (true) Do a boundary check before creating the
  #           histogram.
  #
  # @return [Node] The histogram.
  def histogram( *ret_shape )
    options = ret_shape.last.is_a?( Hash ) ? ret_shape.pop : {}
    options = { :weight => Hornetseye::UINT. new( 1 ), :safe => true }.merge options
    unless options[:weight].matched?
      options[:weight] =
        Hornetseye::Node.match( options[ :weight ] ).maxint.new options[ :weight ]
    end
    weight = options[ :weight ]
    if options[ :safe ]
      if size != ret_shape.size
        raise "Number of arrays for histogram (#{size}) differs from number of " +
              "dimensions of histogram (#{ret_shape.size})"
      end
      source_type = inject { |a,b| a.dimension > b.dimension ? a : b }
      source_type.check_shape *self
      source_type.check_shape options[ :weight ]
      for i in 0 ... size
        range = self[ i ].range 0 ... ret_shape[ i ]
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
    left = Hornetseye::MultiArray(weight.typecode, ret_shape.size).new *ret_shape
    left[] = 0
    block = Hornetseye::Histogram.new left, weight, *self
    if block.compilable?
      Hornetseye::GCCFunction.run block
    else
      block.demand
    end
    left
  end

  # Perform element-wise lookup
  #
  # @param [Node] table The lookup table (LUT).
  # @option options [Boolean] :safe (true) Do a boundary check before creating the
  #         element-wise lookup.
  #
  # @return [Node] The result of the lookup operation.
  def lut( table, options = {} )
    options = { :safe => true }.merge options
    if options[ :safe ]
      if size > table.dimension
        raise "Number of arrays for lookup (#{size}) is greater than the " +
              "number of dimensions of LUT (#{table.dimension})"
      end
      source_type = inject { |a,b| a.dimension > b.dimension ? a : b }
      source_type.check_shape *self
      for i in 0 ... size
        offset = table.dimension - size
        range = self[ i ].range 0 ... table.shape[ i + offset ]
        if range.begin < 0
          raise "#{i+1}th index must be in 0 ... #{table.shape[i]} " +
                "(but was #{range.begin})"
        end
        if range.end >= table.shape[ i + offset ]
          raise "#{i+1}th index must be in 0 ... " +
                "#{table.shape[ i + offset ]} (but was #{range.end})"
        end
      end
    end
    if all? { |source| source.dimension == 0 and source.variables.empty? }
      result = table
      ( table.dimension - 1 ).downto( 0 ) do |i|
        result = result.element( self[ i ].demand ).demand
      end
      result
    else
      Hornetseye::Lut.new( *( self + [ table ] ) ).force
    end
  end

end

