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

  # Representation for colour pixel
  class RGB

    class << self

      # Check compatibility of other type
      #
      # This method checks whether binary operations with the other Ruby object can
      # be performed without requiring coercion.
      #
      # @param [Object] value The other Ruby object.
      #
      # @return [Boolean] Returns +false+ if Ruby object requires
      #         coercion.
      #
      # @private
      def generic?(value)
        value.is_a?(Numeric) or value.is_a?(GCCValue)
      end

      # Defines a unary operation
      #
      # This method uses meta-programming to define channel-wise unary operations.
      #
      # @param [Symbol,String] op Operation to define channel-wise operation.
      #
      # @return [Proc] The new method.
      #
      # @private
      def define_unary_op(op)
        define_method op do
          RGB.new r.send(op), g.send(op), b.send(op)
        end
      end

      # Defines a binary operation
      #
      # This method uses meta-programming to define channel-wise binary operations.
      #
      # @param [Symbol,String] op Operation to define channel-wise operation.
      #
      # @return [Proc] The new method.
      #
      # @private
      def define_binary_op(op)
        define_method op do |other|
          if other.is_a? RGB
            RGB.new r.send( op, other.r ), g.send( op, other.g ),
                    b.send( op, other.b )
          elsif RGB.generic? other
            RGB.new r.send( op, other ), g.send( op, other ),
                    b.send( op, other )
          else
            x, y = other.coerce self
            x.send op, y
          end
        end
      end

    end

    # Access red channel
    #
    # @return [Object] Value of red channel.
    attr_accessor :r

    # Access green channel
    #
    # @return [Object] Value of green channel.
    attr_accessor :g

    # Access blue channel
    #
    # @return [Object] Value of blue channel.
    attr_accessor :b

    # Constructor
    #
    # Create new RGB object.
    #
    # @param [Object] r Red colour component.
    # @param [Object] g Green colour component.
    # @param [Object] b Blue colour component.
    def initialize( r, g, b )
      @r, @g, @b = r, g, b
    end

    # Return string with information about this object
    #
    # @return [String] Returns a string (e.g. "RGB(1,2,3)").
    def inspect
      "RGB(#{@r.inspect},#{@g.inspect},#{@b.inspect})"
    end

    # Return string with information about this object
    #
    # @return [String] Returns a string (e.g. "RGB(1,2,3)").
    def to_s
      "RGB(#{@r.to_s},#{@g.to_s},#{@b.to_s})"
    end

    # Store new value in this RGB object
    #
    # @param [Object] value New value for this object.
    #
    # @return [Object] Returns +value+.
    #
    # @private
    def assign(value)
      @r, @g, @b = value.r, value.g, value.b
    end

    # Coerce with other object
    #
    # @param [RGB] other Other object.
    #
    # @return [Array<RGB>] Result of coercion.
    #
    # @private
    def coerce(other)
      if other.is_a? RGB
        return other, self
      else
        return RGB.new( other, other, other ), self
      end
    end

    # This operation has no effect
    #
    # @return [RGB] Returns +self+.
    def +@
      self
    end

    define_unary_op  :~
    define_unary_op  :-@
    define_unary_op  :floor
    define_unary_op  :ceil
    define_unary_op  :round
    define_binary_op :+
    define_binary_op :-
    define_binary_op :*
    define_binary_op :**
    define_binary_op :/
    define_binary_op :%
    define_binary_op :&
    define_binary_op :|
    define_binary_op :^
    define_binary_op :<<
    define_binary_op :>>
    define_binary_op :minor
    define_binary_op :major

    # Check whether value is equal to zero
    #
    # @return [Boolean,GCCValue] The result.
    def zero?
      @r.zero?.and( @g.zero? ).and( @b.zero? )
    end

    # Check whether value is not equal to zero
    #
    # @return [Boolean,GCCValue] The result.
    def nonzero?
      @r.nonzero?.or( @g.nonzero? ).or( @b.nonzero? )
    end

    # Swap colour channels
    #
    # @return [RGB] The result.
    def swap_rgb
      RGB.new @b, @g, @r
    end

    # Test on equality
    #
    # @param [Object] other Object to compare with.
    #
    # @return [Boolean] Returns boolean indicating whether objects are
    #         equal or not.
    def ==(other)
      if other.is_a? RGB
        @r.eq( other.r ).and( @g.eq( other.g ) ).and( @b.eq( other.b ) )
      elsif RGB.generic? other
        @r.eq(other).and( @g.eq(other) ).and( @b.eq(other) )
      else
        false
      end
    end

    # Decompose RGB number
    #
    # This method decomposes the RGB value into an array.
    #
    # @return [Node] An array with the three channel values as elements.
    #
    # @private
    def decompose(i)
      [ @r, @g, @b ][ i ]
    end

  end

end

module Hornetseye

  # Class for representing native RGB values
  class RGB_ < Composite

    class << self

      # Set base class attribute
      #
      # Sets number of elements to three.
      #
      # @param [Class] subclass The class inheriting from +RGB_+.
      #
      # @return The return value should be ignored.
      #
      # @private
      def inherited(subclass)
        subclass.num_elements = 3
      end

      def inherit(element_type)
        retval = Class.new self
        retval.element_type = element_type
        retval
      end

      # Construct new object from arguments
      #
      # @param [Object] r Value for red channel.
      # @param [Object] g Value for green channel.
      # @param [Object] b Value for blue channel.
      #
      # @return [RGB] New object of this type.
      #
      # @private
      def construct( r, g, b )
        new RGB.new( r, g, b )
      end

      # Get default value for elements of this type
      #
      # @return [Object] Returns +RGB( 0, 0, 0 )+.
      #
      # @private
      def default
        RGB.new 0, 0, 0
      end

      # Identifier array used internally
      #
      # @private
      IDENTIFIER = { BYTE    => 'BYTERGB',
                     UBYTE   => 'UBYTERGB',
                     SINT    => 'SINTRGB',
                     USINT   => 'USINTRGB',
                     INT     => 'INTRGB',
                     UINT    => 'UINTRGB',
                     LONG    => 'LONGRGB',
                     ULONG   => 'ULONGRGB',
                     SFLOAT  => 'SFLOATRGB',
                     DFLOAT  => 'DFLOATRGB' }

      # Diplay information about this class
      #
      # @return [String] Text with information about this class (e.g. "DFLOATRGB").
      def inspect
        unless element_type.nil?
          IDENTIFIER[ element_type ] || "RGB(#{element_type.inspect})"
        else
          super
        end
      end

      # Get corresponding maximum integer type
      #
      # @return [Class] Returns RGB type based on integers.
      #
      # @private
      def maxint
        Hornetseye::RGB element_type.maxint
      end

      # Convert to type based on floating point numbers
      #
      # @return [Class] Corresponding type based on floating point numbers.
      #
      # @private
      def float
        Hornetseye::RGB element_type.float
      end

      # Compute balanced type for binary operation
      #
      # @param [Class] other Other native datatype to coerce with.
      #
      # @return [Class] Result of coercion.
      #
      # @private
      def coercion(other)
        if other < RGB_
          Hornetseye::RGB element_type.coercion( other.element_type )
        elsif other < INT_ or other < FLOAT_
          Hornetseye::RGB element_type.coercion(other)
        else
          super other
        end
      end

      # Type coercion for native elements
      #
      # @param [Class] other Other type to coerce with.
      #
      # @return [Array<Class>] Result of coercion.
      #
      # @private
      def coerce(other)
        if other < RGB_
          return other, self
        elsif other < INT_ or other < FLOAT_
          return Hornetseye::RGB(other), self
        else
          super other
        end
      end

      # Test equality of classes
      #
      # @param [Object] other Object to compare with.
      #
      # @return [Boolean] Boolean indicating whether classes are equal.
      def ==(other)
        other.is_a? Class and other < RGB_ and
          element_type == other.element_type
      end

      # Compute hash value for this class
      #
      # @return [Fixnum] Hash value
      #
      # @private
      def hash
        [ :RGB_, element_type ].hash
      end

      # Equality for hash operations
      #
      # @param [Object] other Object to compare with.
      #
      # @return [Boolean] Returns +true+ if objects are equal.
      #
      # @private
      def eql?(other)
        self == other
      end

      # Check whether this object is an RGB value
      #
      # @return [Boolean] Returns +true+.
      def rgb?
        true
      end

    end

    # Constructor for native RGB value
    #
    # @param [RGB] value Initial RGB value.
    def initialize( value = self.class.default )
      if Thread.current[ :function ].nil? or
         [ value.r, value.g, value.b ].all? { |c| c.is_a? GCCValue }
        @value = value
      else
        r = GCCValue.new Thread.current[ :function ], value.r.to_s
        g = GCCValue.new Thread.current[ :function ], value.g.to_s
        b = GCCValue.new Thread.current[ :function ], value.b.to_s
        @value = RGB.new r, g, b
      end
    end

    # Duplicate object
    #
    # @return [RGB_] Duplicate of +self+.
    def dup
      if Thread.current[ :function ]
        r = Thread.current[ :function ].variable self.class.element_type, 'v'
        g = Thread.current[ :function ].variable self.class.element_type, 'v'
        b = Thread.current[ :function ].variable self.class.element_type, 'v'
        r.assign @value.r
        g.assign @value.g
        b.assign @value.b
        self.class.new RGB.new( r, g, b )
      else
        self.class.new get
      end
    end

    # Store new value in this object
    #
    # @param [Object] value New value for this object.
    #
    # @return [Object] Returns +value+.
    #
    # @private
    def assign(value)
      value = value.simplify
      if @value.r.respond_to? :assign
        @value.r.assign value.get.r
      else
        @value.r = value.get.r
      end
      if @value.g.respond_to? :assign
        @value.g.assign value.get.g
      else
        @value.g = value.get.g
      end
      if @value.b.respond_to? :assign
        @value.b.assign value.get.b
      else
        @value.b = value.get.b
      end
      value
    end

    # Get values of composite number
    #
    # @return [Array<Object>] Returns array with red, green, and blue component.
    #
    # @private
    def values
      [ @value.r, @value.g, @value.b ]
    end

    # Namespace containing method for matching elements of type RGB_
    #
    # @see RGB_
    #
    # @private
    module Match

      # Method for matching elements of type RGB_
      #
      # @param [Array<Object>] *values Values to find matching native element
      #        type for.
      #
      # @return [Class] Native type fitting all values.
      #
      # @see RGB_
      #
      # @private
      def fit( *values )
        if values.all? { |value| value.is_a? RGB or value.is_a? Float or
                                 value.is_a? Integer }
          if values.any? { |value| value.is_a? RGB }
            elements = values.inject([]) do |arr,value|
              if value.is_a? RGB
                arr + [ value.r, value.g, value.b ]
              else
                arr + [ value ]
              end
            end
            element_fit = fit *elements
            if element_fit == OBJECT
              super *values
            else
              Hornetseye::RGB element_fit
            end
          else
            super *values
          end
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
        if self < RGB_
          Hornetseye::RGB element_type.align(context)
        else
          super context
        end
      end

    end

    Node.extend Match

  end

  class Node

    define_unary_op :r, :scalar
    define_unary_op :g, :scalar
    define_unary_op :b, :scalar
    define_unary_op :swap_rgb

    # Fast extraction for red channel of RGB array
    #
    # @return [Node] Array with red channel.
    def r_with_decompose
      if typecode == OBJECT or is_a?(Variable) or Thread.current[:lazy]
        r_without_decompose
      elsif typecode < RGB_
        decompose 0
      else
        self
      end
    end

    alias_method_chain :r, :decompose

    # Assignment for red channel values of RGB array
    #
    # @param [Object] Value or array of values to assign to red channel.
    #
    # @return [Object] Returns +value+.
    def r=(value)
      if typecode < RGB_
        decompose( 0 )[] = value
      elsif typecode == OBJECT
        self[] = Hornetseye::lazy do
          value * RGB.new( 1, 0, 0 ) + g * RGB.new( 0, 1, 0 ) + b * RGB.new( 0, 0, 1 )
        end
      else
        raise "Cannot assign red channel to elements of type #{typecode.inspect}"
      end
    end

    # Fast extraction for green channel of RGB array
    #
    # @return [Node] Array with green channel.
    def g_with_decompose
      if typecode == OBJECT or is_a?(Variable) or Thread.current[:lazy]
        g_without_decompose
      elsif typecode < RGB_
        decompose 1
      else
        self
      end
    end

    alias_method_chain :g, :decompose

    # Assignment for green channel values of RGB array
    #
    # @param [Object] Value or array of values to assign to green channel.
    #
    # @return [Object] Returns +value+.
    def g=(value)
      if typecode < RGB_
        decompose( 1 )[] = value
      elsif typecode == OBJECT
        self[] = Hornetseye::lazy do
          r * RGB.new( 1, 0, 0 ) + value * RGB.new( 0, 1, 0 ) + b * RGB.new( 0, 0, 1 )
        end
      else
        raise "Cannot assign green channel to elements of type #{typecode.inspect}"
      end
    end

    # Fast extraction for blue channel of RGB array
    #
    # @return [Node] Array with blue channel.
    def b_with_decompose
      if typecode == OBJECT or is_a?(Variable) or Thread.current[:lazy]
        b_without_decompose
      elsif typecode < RGB_
        decompose 2
      else
        self
      end
    end

    alias_method_chain :b, :decompose

    # Assignment for blue channel values of RGB array
    #
    # @param [Object] Value or array of values to assign to blue channel.
    #
    # @return [Object] Returns +value+.
    def b=(value)
      if typecode < RGB_
        decompose( 2 )[] = value
      elsif typecode == OBJECT
        self[] = Hornetseye::lazy do
          r * RGB.new( 1, 0, 0 ) + g * RGB.new( 0, 1, 0 ) + value * RGB.new( 0, 0, 1 )
        end
      else
        raise "Cannot assign blue channel to elements of type #{typecode.inspect}"
      end
    end

    # Swapping colour channels for scalar values
    #
    # @return [Node] Array with swapped colour channels.
    def swap_rgb_with_scalar
      if typecode == OBJECT or typecode < RGB_
        swap_rgb_without_scalar
      else
        self
      end
    end

    alias_method_chain :swap_rgb, :scalar

    # Compute colour histogram of this array
    #
    # The array is decomposed to its colour channels and a histogram is computed.
    #
    # @overload histogram( *ret_shape, options = {} )
    #   @param [Array<Integer>] ret_shape Dimensions of resulting histogram.
    #   @option options [Node] :weight (Hornetseye::UINT(1)) Weights for computing the
    #           histogram.
    #   @option options [Boolean] :safe (true) Do a boundary check before creating the
    #           histogram.
    #
    # @return [Node] The histogram.
    def histogram_with_rgb( *ret_shape )
      if typecode < RGB_
        [ r, g, b ].histogram *ret_shape
      else
        histogram_without_rgb *ret_shape
      end
    end

    alias_method_chain :histogram, :rgb

    # Perform element-wise lookup with colour values
    #
    # @param [Node] table The lookup table (LUT).
    # @option options [Boolean] :safe (true) Do a boundary check before creating the
    #         element-wise lookup.
    #
    # @return [Node] The result of the lookup operation.
    def lut_with_rgb( table, options = {} )
      if typecode < RGB_
        [ r, g, b ].lut table, options
      else
        lut_without_rgb table, options
      end
    end

    alias_method_chain :lut, :rgb

  end

  # Create a class deriving from +RGB_+ or instantiate an +RGB+ object
  #
  # @overload RGB( element_type )
  #   Create a class deriving from +RGB_+. The parameters +element_type+ is
  #   assigned to the corresponding attribute of the resulting class.
  #   @param [Class] element_type Element type of native RGB value.
  #   @return [Class] A class deriving from +RGB_+.
  #
  # @overload RGB( r, g, b )
  #   This is a shortcut for +RGB.new( r, g, b )+.
  #   @param [Object] r Initial value for red channel.
  #   @param [Object] g Initial value for green channel.
  #   @param [Object] b Initial value for blue channel.
  #   @return [RGB] The RGB value.
  #
  # @return [Class,RGB] A class deriving from +RGB_+ or an RGB value.
  #
  # @see RGB_
  # @see RGB_.element_type
  def RGB( arg, g = nil, b = nil )
    if g.nil? and b.nil?
      RGB_.inherit arg
    else
      RGB.new arg, g, b
    end
  end

  module_function :RGB

  # 24-bit unsigned RGB-triplet
  BYTERGB   = RGB BYTE

  # 24-bit signed RGB-triplet
  UBYTERGB  = RGB UBYTE

  # 48-bit unsigned RGB-triplet
  SINTRGB   = RGB SINT

  # 48-bit signed RGB-triplet
  USINTRGB  = RGB USINT

  # 96-bit unsigned RGB-triplet
  INTRGB    = RGB INT

  # 96-bit signed RGB-triplet
  UINTRGB   = RGB UINT

  # 192-bit unsigned RGB-triplet
  LONGRGB   = RGB LONG

  # 192-bit signed RGB-triplet
  ULONGRGB  = RGB ULONG

  # single precision RGB-triplet
  SFLOATRGB = RGB SFLOAT

  # double precision RGB-triplet
  DFLOATRGB = RGB DFLOAT

  # Shortcut for constructor
  #
  # The method calls +BYTERGB.new+.
  #
  # @param [RGB] value RGB value.
  #
  # @return [BYTERGB] The wrapped RGB value.
  #
  # @private
  def BYTERGB(value)
    BYTERGB.new value
  end

  # Shortcut for constructor
  #
  # The method calls +UBYTERGB.new+.
  #
  # @param [RGB] value RGB value.
  #
  # @return [UBYTERGB] The wrapped RGB value.
  #
  # @private
  def UBYTERGB(value)
    UBYTERGB.new value
  end

  # Shortcut for constructor
  #
  # The method calls +SINTRGB.new+.
  #
  # @param [RGB] value RGB value.
  #
  # @return [SINTRGB] The wrapped RGB value.
  #
  # @private
  def SINTRGB(value)
    SINTRGB.new value
  end

  # Shortcut for constructor
  #
  # The method calls +USINTRGB.new+.
  #
  # @param [RGB] value RGB value.
  #
  # @return [USINTRGB] The wrapped RGB value.
  #
  # @private
  def USINTRGB(value)
    USINTRGB.new value
  end

  # Shortcut for constructor
  #
  # The method calls +INTRGB.new+.
  #
  # @param [RGB] value RGB value.
  #
  # @return [INTRGB] The wrapped RGB value.
  #
  # @private
  def INTRGB(value)
    INTRGB.new value
  end

  # Shortcut for constructor
  #
  # The method calls +UINTRGB.new+.
  #
  # @param [RGB] value RGB value.
  #
  # @return [UINTRGB] The wrapped RGB value.
  #
  # @private
  def UINTRGB(value)
    UINTRGB.new value
  end

  # Shortcut for constructor
  #
  # The method calls +LONGRGB.new+.
  #
  # @param [RGB] value RGB value.
  #
  # @return [LONGRGB] The wrapped RGB value.
  #
  # @private
  def LONGRGB(value)
    LONGRGB.new value
  end

  # Shortcut for constructor
  #
  # The method calls +ULONGRGB.new+.
  #
  # @param [RGB] value RGB value.
  #
  # @return [ULONGRGB] The wrapped RGB value.
  #
  # @private
  def ULONGRGB(value)
    ULONGRGB.new value
  end

  # Shortcut for constructor
  #
  # The method calls +SFLOATRGB.new+.
  #
  # @param [RGB] value RGB value.
  #
  # @return [SFLOATRGB] The wrapped RGB value.
  #
  # @private
  def SFLOATRGB(value)
    SFLOATRGB.new value
  end

  # Shortcut for constructor
  #
  # The method calls +DFLOATRGB.new+.
  #
  # @param [RGB] value RGB value.
  #
  # @return [DFLOATRGB] The wrapped RGB value.
  #
  # @private
  def DFLOATRGB(value)
    DFLOATRGB.new value
  end

  module_function :BYTERGB
  module_function :UBYTERGB
  module_function :SINTRGB
  module_function :USINTRGB
  module_function :INTRGB
  module_function :UINTRGB
  module_function :LONGRGB
  module_function :ULONGRGB
  module_function :SFLOATRGB
  module_function :DFLOATRGB

end

# The +Numeric+ class is extended with a few methods
class Numeric

  # Get red component
  #
  # @return [Numeric] Returns +self+.
  def r
    self
  end

  # Get green component
  #
  # @return [Numeric] Returns +self+.
  def g
    self
  end

  # Get blue component
  #
  # @return [Numeric] Returns +self+.
  def b
    self
  end

  # Swap colour channels
  #
  # @return [Numeric] Returns +self+.
  def swap_rgb
    self
  end

end

class Fixnum

  if method_defined? :rpower

    # +**+ is modified to work with RGB values
    #
    # @param [Object] other Second operand for binary operation.
    # @return [Object] Result of binary operation.
    #
    # @private
    def power_with_rgb(other)
      if other.is_a? Hornetseye::RGB
        x, y = other.coerce self
        x ** y
      else
        power_without_rgb other
      end
    end

    alias_method_chain :**, :rgb, :power

  end

end

module Math

  def sqrt_with_rgb(c)
    if c.is_a? Hornetseye::RGB
      Hornetseye::RGB.new sqrt( c.r ), sqrt( c.g ), sqrt( c.b )
    else
      sqrt_without_rgb c
    end
  end

  alias_method_chain :sqrt, :rgb
  module_function :sqrt_without_rgb
  module_function :sqrt

  def log_with_rgb(c)
    if c.is_a? Hornetseye::RGB
      Hornetseye::RGB.new log( c.r ), log( c.g ), log( c.b )
    else
      log_without_rgb c
    end
  end

  alias_method_chain :log, :rgb
  module_function :log_without_rgb
  module_function :log

end

