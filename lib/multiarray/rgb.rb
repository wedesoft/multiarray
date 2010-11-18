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
      def generic?( value )
        value.is_a?( Numeric ) or value.is_a?( GCCValue )
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
      def define_unary_op( op )
        define_method( op ) do
          RGB.new r.send( op ), g.send( op ), b.send( op )
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
      def define_binary_op( op )
        define_method( op ) do |other|
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
    def store( value )
      @r, @g, @b = value.r, value.g, value.b
    end

    def coerce( other )
      if other.is_a? RGB
        return other, self
      else
        return RGB.new( other, other, other ), self
      end
    end

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

    def zero?
      @r.zero?.and( @g.zero? ).and( @b.zero? )
    end

    def nonzero?
      @r.nonzero?.or( @g.nonzero? ).or( @b.nonzero? )
    end

    def ==( other )
      if other.is_a? RGB
        @r.eq( other.r ).and( @g.eq( other.g ) ).and( @b.eq( other.b ) )
      elsif RGB.generic? other
        @r.eq( other ).and( @g.eq( other ) ).and( @b.eq( other ) )
      else
        false
      end
    end

    # Decompose RGB number
    #
    # This method decomposes the RGB value into an array.
    #
    # @return [Node] An array with the three channel values as elements.
    def decompose( i )
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
      def inherited( subclass )
        subclass.num_elements = 3
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
          retval = IDENTIFIER[ element_type ] || "RGB(#{element_type.inspect})"
          ( class << self; self; end ).instance_eval do
            define_method( :inspect ) { retval }
          end
          retval
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
      def coercion( other )
        if other < RGB_
          Hornetseye::RGB element_type.coercion( other.element_type )
        elsif other < INT_ or other < FLOAT_
          Hornetseye::RGB element_type.coercion( other )
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
      def coerce( other )
        if other < RGB_
          return other, self
        elsif other < INT_ or other < FLOAT_
          return Hornetseye::RGB( other ), self
        else
          super other
        end
      end

      # Test equality of classes
      #
      # @param [Object] other Object to compare with.
      #
      # @return [Boolean] Boolean indicating whether classes are equal.
      def ==( other )
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
      def eql?( other )
        self == other
      end

      def rgb?
        true
      end

    end

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
        r.store @value.r
        g.store @value.g
        b.store @value.b
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
    def store( value )
      value = value.simplify
      if @value.r.respond_to? :store
        @value.r.store value.get.r
      else
        @value.r = value.get.r
      end
      if @value.g.respond_to? :store
        @value.g.store value.get.g
      else
        @value.g = value.get.g
      end
      if @value.b.respond_to? :store
        @value.b.store value.get.b
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
            elements = values.inject( [] ) do |arr,value|
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
      def align( context )
        if self < RGB_
          Hornetseye::RGB element_type.align( context )
        else
          super context
        end
      end

    end

    Node.extend Match

  end

  module Operations

    define_unary_op :r, :scalar
    define_unary_op :g, :scalar
    define_unary_op :b, :scalar

    def r_with_decompose
      if typecode == OBJECT or is_a?( Variable )
        r_without_decompose
      elsif typecode < RGB_
        decompose 0
      else
        self
      end
    end

    alias_method_chain :r, :decompose

    def r=( value )
      if typecode < RGB_
        decompose( 0 )[] = value
      elsif typecode == OBJECT
        self[] = Hornetseye::lazy do
          value * RGB.new( 1, 0, 0 ) + g * RGB.new( 0, 1, 0 ) + b * RGB.new( 0, 0, 1 )
        end
      else
        raise "Cannot assign red channel to object of type #{array_type.inspect}"
      end
    end

    def g_with_decompose
      if typecode == OBJECT or is_a?( Variable )
        g_without_decompose
      elsif typecode < RGB_
        decompose 1
      else
        self
      end
    end

    alias_method_chain :g, :decompose

    def g=( value )
      if typecode < RGB_
        decompose( 1 )[] = value
      elsif typecode == OBJECT
        self[] = Hornetseye::lazy do
          r * RGB.new( 1, 0, 0 ) + value * RGB.new( 0, 1, 0 ) + b * RGB.new( 0, 0, 1 )
        end
      else
        raise "Cannot assign green channel to object of type #{array_type.inspect}"
      end
    end

    def b_with_decompose
      if typecode == OBJECT or is_a?( Variable )
        b_without_decompose
      elsif typecode < RGB_
        decompose 2
      else
        self
      end
    end

    alias_method_chain :b, :decompose

    def b=( value )
      if typecode < RGB_
        decompose( 2 )[] = value
      elsif typecode == OBJECT
        self[] = Hornetseye::lazy do
          r * RGB.new( 1, 0, 0 ) + g * RGB.new( 0, 1, 0 ) + value * RGB.new( 0, 0, 1 )
        end
      else
        raise "Cannot assign blue channel to object of type #{array_type.inspect}"
      end
    end

  end

  def RGB( arg, g = nil, b = nil )
    if g.nil? and b.nil?
      retval = Class.new RGB_
      retval.element_type = arg
      retval
    else
      RGB.new arg, g, b
    end
  end

  module_function :RGB

  BYTERGB   = RGB BYTE

  UBYTERGB  = RGB UBYTE

  SINTRGB   = RGB SINT

  USINTRGB  = RGB USINT

  INTRGB    = RGB INT

  UINTRGB   = RGB UINT

  LONGRGB   = RGB LONG

  ULONGRGB  = RGB ULONG

  SFLOATRGB = RGB SFLOAT

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
  def BYTERGB( value )
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
  def UBYTERGB( value )
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
  def SINTRGB( value )
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
  def USINTRGB( value )
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
  def INTRGB( value )
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
  def UINTRGB( value )
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
  def LONGRGB( value )
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
  def ULONGRGB( value )
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
  def SFLOATRGB( value )
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
  def DFLOATRGB( value )
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

class Fixnum

  if method_defined? :rpower

    def power_with_rgb( other )
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

