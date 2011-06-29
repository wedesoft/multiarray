# multiarray - Lazy multi-dimensional arrays for Ruby
# Copyright (C) 2010, 2011 Jan Wedekind
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

  # Class for representing n-dimensional native arrays
  class Field_

    class << self

      # Type of array elements
      #
      # @return [Class] Type of array elements.
      attr_accessor :typecode

      # Number of dimensions
      #
      # @return [Integer] Number of dimensions.
      attr_accessor :dimension

      @@subclasses = {}

      def inherit(typecode, dimension)
        if @@subclasses.has_key? [typecode, dimension]
          @@subclasses[[typecode, dimension]]
        else
          retval = Class.new self
          retval.typecode = typecode
          retval.dimension = dimension
          @@subclasses[[typecode, dimension]] = retval
        end
      end

      # Display this type
      #
      # @return [String] String with description of this type.
      def inspect
        if typecode and dimension
          if dimension != 1
            "MultiArray(#{typecode.inspect},#{dimension})"
          else
            "Sequence(#{typecode.inspect})"
          end
        else
          'Field(?,?)'
        end
      end

      def to_s
        inspect
      end

      # Construct native array from Ruby array
      #
      # @param [Array<Object>] args Array with Ruby values.
      #
      # @return [Node] Native array with specified values.
      def [](*args)
        def arr_shape(args)
          if args.is_a? Array
            args.collect do |arg|
              arr_shape arg
            end.inject([]) do |a,b|
              (0 ... [a.size, b.size].max).collect do |i|
                [i < a.size ? a[i] : 0, i < b.size ? b[i] : 0].max
              end
            end + [args.size]
          else
            []
          end
        end
        retval = new *arr_shape(args)
        def recursion(element, args)
          if element.dimension > 0
            args.each_with_index do |arg,i|
              recursion element.element(INT.new(i)), arg
            end
          else
            element[] = args
          end
        end
        recursion retval, args
        retval
      end

      # Create (lazy) index array
      #
      # @overload indgen(*shape, offset = 0, increment = 1)
      #   @param [Array<Integer>] shape Dimensions of resulting array.
      #   @param [Object] offset (0) First value of array.
      #   @param [Object] increment (1) Increment for subsequent values.
      #
      # @return [Node] Lazy term generating the array.
      def indgen(*args)
        unless args.size.between? dimension, dimension + 2
          raise "#{inspect}.indgen requires between #{dimension} and #{dimension + 2} arguments"
        end
        shape = args[0 ... dimension]
        offset = args.size > dimension ? args[dimension] : 0
        increment = args.size > dimension + 1 ? args[dimension + 1] : 1
        step = shape[0 ... -1].inject 1, :*
        Hornetseye::lazy(shape.last) do |i|
          (step * increment * i +
           Hornetseye::MultiArray(typecode, dimension - 1).
             indgen(*(shape[0 ... -1] + [offset, increment]))).to_type typecode
        end
      end

      # Generate random number array
      #
      # Generate integer or floating point random numbers in the range 0 ... n.
      #
      # @overload random(*shape, n)
      #   @param [Array<Integer>] shape Dimensions of resulting array.
      #   @param [Integer,Float] n (1) Upper boundary for random numbers
      #
      # @return [Node] Array with random numbers.
      def random(*args)
        unless args.size.between? dimension, dimension + 1
          raise "#{inspect}.random requires between #{dimension} and #{dimension + 1} arguments"
        end
        shape = args[0 ... dimension]
        n = args.size > dimension ? args[dimension] : 1
        n = typecode.maxint.new n unless n.matched?
        retval = new *shape
        unless compilable? and dimension > 0
          Random.new(retval.sexp, n).demand
        else
          GCCFunction.run Random.new(retval.sexp, n)
        end
        retval
      end

      # Base type of this data type
      #
      # @return [Class] Returns +element_type+.
      #
      # @private
      def basetype
        typecode.basetype
      end

      # Get storage size of array type
      #
      # @param [Array<Integer>] shape Shape of desired array.
      #
      # @return [Integer] Storage size of array.
      def storage_size(*shape)
        shape.inject typecode.storage_size, :*
      end

      # Type coercion for native elements
      #
      # @param [Class] other Other native datatype to coerce with.
      #
      # @return [Class] Result of coercion.
      #
      # @private
      def coercion( other )
        Hornetseye::MultiArray typecode.coercion(other.typecode),
                          [dimension, other.dimension].max
      end

      # Check whether delayed operation will have colour
      #
      # @return [Boolean] Boolean indicating whether the array has elements of type
      #         RGB.
      def rgb?
        typecode.rgb?
      end

      # Get this type
      #
      # @return [Class] Returns +self+.
      #
      # @private
      def identity
        self
      end

      # Get corresponding boolean type
      #
      # @return [Class] Returns type for array of boolean values.
      #
      # @private
      def bool
        Hornetseye::MultiArray typecode.bool, dimension
      end

      # Coerce and convert to boolean type
      #
      # @return [Class] Returns type for array of boolean values.
      #
      # @private
      def coercion_bool(other)
        coercion(other).bool
      end

      # Get corresponding scalar type
      #
      # @return [Class] Returns type for array of scalars.
      #
      # @private
      def scalar
        Hornetseye::MultiArray typecode.scalar, dimension
      end

      # Get corresponding floating point type
      #
      # @return [Class] Returns type for array of floating point numbers.
      #
      # @private
      def float_scalar
        Hornetseye::MultiArray typecode.float_scalar, dimension
      end

      # Get corresponding maximum integer type
      #
      # @return [Class] Returns type based on maximum integers.
      #
      # @private
      def maxint
        Hornetseye::MultiArray typecode.maxint, dimension
      end

      # Coerce and convert to maximum integer type
      #
      # @return [Class] Returns type based on maximum integers.
      #
      # @private
      def coercion_maxint(other)
        coercion(other).maxint
      end

      # Get corresponding byte type
      #
      # @return [Class] Returns type based on byte.
      #
      # @private
      def byte
        Hornetseye::MultiArray typecode.byte, dimension
      end

      # Coerce and convert to byte type
      #
      # @return [Class] Returns type based on byte.
      #
      # @private
      def coercion_byte(other)
        coercion(other).byte
      end

      # Convert to type based on floating point numbers
      #
      # @return [Class] Corresponding type based on floating point numbers.
      #
      # @private
      def float
        Hornetseye::MultiArray typecode.field, dimension
      end

      # Coerce and convert to type based on floating point numbers
      #
      # @return [Class] Corresponding type based on floating point numbers.
      #
      # @private
      def floating(other)
        coercion(other).float
      end

      # Coerce with two other types
      #
      # @return [Class] Result of coercion.
      #
      # @private
      def cond(a, b)
        t = a.coercion b
        Hornetseye::MultiArray t.typecode, dimension
      end

      # Replace element type
      #
      # @return [Class] Result of conversion.
      #
      # @private
      def to_type(dest)
        Hornetseye::MultiArray typecode.to_type(dest), dimension
      end

      # Check whether this array expression allows compilation
      #
      # @return [Boolean] Returns +true+ if this expression supports compilation.
      def compilable?
        typecode.compilable?
      end

    end

    attr_reader :shape

    def initialize(*shape)
      options = shape.last.is_a?(Hash) ? shape.pop : {}
      raise "Constructor requires #{dimension} arguments" unless dimension == shape.size
      @shape = shape
      @strides = options[:strides] ||
                 (0 ... dimension).collect { |i| shape[0 ... i].inject 1, :* }
      size = shape.inject 1, :*
      @memory = options[:memory] || typecode.memory_type.new(typecode.storage_size * size)
    end

    def sexp?
      true
    end

    def inspect
      sexp.inspect
    end

    def to_s
      "#{self.class.to_s}(#{@memory.inspect},#{@shape.inspect},#{@strides.inspect})"
    end

    def matched?
      true
    end

    def typecode
      self.class.typecode
    end

    def dimension
      self.class.dimension
    end

    def dup
      self.class.new *(@shape +[:strides => @strides, :memory => @memory.dup])
    end

    def sexp
      if dimension > 0
        Hornetseye::lazy(@shape.last) do |index|
          pointer = Field_.inherit(typecode, dimension - 1).
            new(*(@shape[0 ... dimension - 1] +
                [:strides => @strides[0 ... @strides.size - 1], :memory => @memory])).sexp
          Lookup.new pointer, index, INT.new(@strides.last)
        end
      else
        Hornetseye::Pointer(typecode).new @memory
      end
    end

    def element(i)
      memory = @memory + typecode.storage_size * i.get * @strides.last
      if dimension > 1
        Hornetseye::MultiArray(typecode, dimension - 1).
          new *(shape[0 ... dimension - 1] +
                [:strides => @strides[0 ... dimension - 1], :memory => memory])
      else
        Hornetseye::Pointer(typecode).new memory
      end
    end

    def values
      [@memory] + @strides + @shape
    end

    # temporary!!!
    def method_missing(method, *args, &block)
      sexp.send method, *args.collect { |arg| arg.sexp }, &block
    end

    def ==(other)
      sexp == other.sexp
    end

    def to_a
      sexp.to_a
    end

    def to_type(dest)
      if dest == typecode
        self
      else
        if Thread.current[:lazy]
          sexp.to_type dest
        else
          begin
            _to_type dest
          rescue NameError
            keys, values, term = sexp.strip
            subst = Hash[*keys.zip(values).flatten]
            expr = Hornetseye::lazy { term.to_type dest }
            if expr.compilable?
              retval = expr.subst(subst).allocate
              retval_keys, retval_values, retval_term = retval.sexp.strip
              store = Store.new retval_term, expr
              data_keys, data_values, data_term = store.strip
              keys = retval_keys + keys + data_keys
              method_name = GCCFunction.compile data_term, *keys
              GCCCache.const_set "DATA#{method_name}",
                                 data_values.collect { |arg| arg.values }.flatten
              self.class.class_eval <<EOS
def _to_type(dest)
  dest._to_type_#{self.class.to_s.method_name} self
end
EOS
              dest.instance_eval <<EOS
def _to_type_#{self.class.to_s.method_name}(_self)
  retval = Hornetseye::MultiArray(Hornetseye::#{retval.typecode}, #{retval.dimension}).
    new *_self.shape
  GCCCache.#{method_name} *(retval.values + _self.values + GCCCache::DATA#{method_name})
  retval
end
EOS
              _to_type dest
            else
              expr.subst(subst).force
            end
          end
        end
      end
    end

    def conditional(a, b)
      a = Node.match(a, b.matched? ? b : nil).new a unless a.matched?
      b = Node.match(b, a.matched? ? a : nil).new b unless b.matched?
      if Thread.current[:lazy] or a.sexp? or b.sexp?
        sexp.conditional a.sexp, b.sexp
      else
        begin
          _conditional a, b
        rescue NameError
          keys, values, expr = Hornetseye::lazy { conditional a, b }.strip
          subst = Hash[*keys.zip(values).flatten]
          if expr.compilable?
            retval = expr.subst(subst).allocate
            retval_keys, retval_values, retval_term = retval.sexp.strip
            store = Store.new retval_term, expr
            keys = retval_keys + keys
            method_name = GCCFunction.compile store, *keys
            self.class.class_eval <<EOS
def _conditional(a, b)
  a._conditional_#{self.class.to_s.method_name} self, b
end
EOS
            a.class.class_eval <<EOS
def _conditional_#{self.class.to_s.method_name}(_self, b)
  b._conditional_#{self.class.to_s.method_name}_#{a.class.to_s.method_name} _self, self
end
EOS
            dimensions = [dimension, a.dimension, b.dimension]
            b.class.class_eval <<EOS
def _conditional_#{self.class.to_s.method_name}_#{a.class.to_s.method_name}(_self, a)
  retval = Hornetseye::MultiArray(Hornetseye::#{retval.typecode}, #{retval.dimension}).
    new *#{['_self.shape', 'a.shape', 'shape'][dimensions.index(dimensions.max)]}
  GCCCache.#{method_name} *(retval.values + _self.values + a.values + values)
  retval
end
EOS
            _conditional a, b
          else
            expr.subst(subst).force
          end
        end
      end
    end

    def <=>(other)
      other = Node.match(other).new other unless other.matched?
      if Thread.current[:lazy] or other.sexp?
        sexp <=> other.sexp
      else
        begin
          _cmp other
        rescue NameError
          keys, values, term = sexp.strip
          other_keys, other_values, other_term = other.sexp.strip
          subst = Hash[*(keys + other_keys).zip(values + other_values).flatten]
          expr = Hornetseye::lazy { term <=> other_term }
          if expr.compilable?
            retval = expr.subst(subst).allocate
            retval_keys, retval_values, retval_term = retval.sexp.strip
            store = Store.new retval_term, expr
            data_keys, data_values, data_term = store.strip
            keys = retval_keys + keys + other_keys + data_keys
            method_name = GCCFunction.compile data_term, *keys
            GCCCache.const_set "DATA#{method_name}",
                               data_values.collect { |arg| arg.values }.flatten
            self.class.class_eval <<EOS
def _cmp(other)
  other._cmp_#{self.class.to_s.method_name} self
end
EOS
            other.class.class_eval <<EOS
def _cmp_#{self.class.to_s.method_name}(_self)
  retval = Hornetseye::MultiArray(Hornetseye::#{retval.typecode}, #{retval.dimension}).
    new *#{other.dimension > dimension ? 'shape' : '_self.shape'}
  GCCCache.#{method_name} *(retval.values + _self.values + values +
                            GCCCache::DATA#{method_name})
  retval
end
EOS
            _cmp other
          else
            expr.subst(subst).force
          end
        end
      end
    end

    Scalar.class_eval do
      def <=>(other)
        @value <=> other.sexp
      end
    end

    def inject(initial = nil, options = {}, &action)
      sexp.inject initial, options, &action
    end

    def collect(&action)
      sexp.collect &action
    end

    alias_method :map, :collect

    def each(&action)
      sexp.each &action
    end

    def demand
      self
    end

    def get
      self
    end

    # Coerce with other object
    #
    # @param [Object] other Other object.
    #
    # @return [Array<Object>] Result of coercion.
    #
    # @private
    def coerce(other)
      if other.is_a? Node
        return other, sexp
      elsif other.is_a? Field_
        return other, self
      else
        return Scalar.new(other), self
      end
    end

    # Namespace containing method for matching elements of type Field_
    #
    # @see Field_
    #
    # @private
    module Match

      # Method for matching elements of type Field_
      #
      # @param [Array<Object>] *values Values to find matching native element
      #        type for.
      #
      # @return [Class] Native type fitting all values.
      #
      # @see Field_
      #
      # @private
      def fit( *values )
        n = values.inject 0 do |size,value|
          value.is_a?(Array) ? [size, value.size].max : size
        end
        if n > 0
          elements = values.inject [] do |flat,value|
            flat + (value.is_a?(Array) ? value : [value])
          end
          Hornetseye::MultiArray fit( *elements ), 1
        else
          super *values
        end
      end

      # Perform type alignment
      #
      # Align this type to another. This is used to prefer single-precision
      # floating point in certain cases.
      #
      # @param [Class] context Other type to align with.
      #
      # @private
      def align(context)
        if self < Field_
          Hornetseye::MultiArray typecode.align(context), dimension
        else
          super context
        end
      end

    end

    Node.extend Match

  end

end

