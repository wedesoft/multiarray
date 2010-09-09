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

  class RGB

    class << self

      def generic?( value )
        value.is_a?( Numeric ) or value.is_a?( GCCValue )
      end

      def define_unary_op( op )
        define_method( op ) do
          RGB.new r.send( op ), g.send( op ), b.send( op )
        end
      end

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

    attr_accessor :r, :g, :b

    def initialize( r, g, b )
      @r, @g, @b = r, g, b
    end

    def inspect
      "RGB(#{@r.inspect},#{@g.inspect},#{@b.inspect})"
    end

    def to_s
      "RGB(#{@r.to_s},#{@g.to_s},#{@b.to_s})"
    end

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
    define_binary_op :+
    define_binary_op :-
    define_binary_op :*
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

    def decompose
      Hornetseye::Sequence[ @r, @g, @b ]
    end

  end

  class RGB_ < Element

    class << self

      attr_accessor :element_type

      def fetch( ptr )
        construct *ptr.load( self )
      end

      def construct( r, g, b )
        new RGB.new( r, g, b )
      end

      def memory
        element_type.memory
      end

      def storage_size
        element_type.storage_size * 3
      end

      def default
        RGB.new 0, 0, 0
      end

      def directive
        element_type.directive * 3
      end

      def inspect
        unless element_type.nil?
          { BYTE    => 'BYTERGB',
            UBYTE   => 'UBYTERGB',
            SINT    => 'SINTRGB',
            USINT   => 'USINTRGB',
            INT     => 'INTRGB',
            UINT    => 'UINTRGB',
            LONG    => 'LONGRGB',
            ULONG   => 'ULONGRGB',
            SFLOAT  => 'SFLOATRGB',
            DFLOAT  => 'DFLOATRGB' }[ element_type ] ||
            "RGB(#{element_type.inspect})"
        else
          super
        end
      end

      def descriptor( hash )
        unless element_type.nil?
          inspect
        else
          super
        end
      end

      def basetype
        element_type
      end

      def typecodes
        [ element_type ] * 3
      end

      def scalar
        element_type
      end

      def maxint
        Hornetseye::RGB element_type.maxint
      end

      def float
        Hornetseye::RGB element_type.float
      end

      def coercion( other )
        if other < RGB_
          Hornetseye::RGB element_type.coercion( other.element_type )
        elsif other < INT_ or other < FLOAT_
          Hornetseye::RGB element_type.coercion( other )
        else
          super other
        end
      end

      def coerce( other )
        if other < RGB_
          return other, self
        elsif other < INT_ or other < FLOAT_
          return Hornetseye::RGB( other ), self
        else
          super other
        end
      end

      def ==( other )
        other.is_a? Class and other < RGB_ and
          element_type == other.element_type
      end

      def hash
        [ :RGB_, element_type ].hash
      end

      def eql?( other )
        self == other
      end

      def decompose
        Hornetseye::Sequence( self.class.element_type,
                              3 )[ @value.r, @value.g, @value.b ]
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

    def values
      [ @value.r, @value.g, @value.b ]
    end

    module Match

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

  def BYTERGB( value )
    BYTERGB.new value
  end

  def UBYTERGB( value )
    UBYTERGB.new value
  end

  def SINTRGB( value )
    SINTRGB.new value
  end

  def USINTRGB( value )
    USINTRGB.new value
  end

  def INTRGB( value )
    INTRGB.new value
  end

  def UINTRGB( value )
    UINTRGB.new value
  end

  def LONGRGB( value )
    LONGRGB.new value
  end

  def ULONGRGB( value )
    ULONGRGB.new value
  end

  def SFLOATRGB( value )
    SFLOATRGB.new value
  end

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
