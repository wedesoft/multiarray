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

  class Complex

    class << self

      def generic?( value )
        value.is_a?( Numeric ) or value.is_a?( GCCValue )
      end

      def polar( r, theta )
        new r * Math.cos( theta ), r * Math.sin( theta )
      end

    end

    attr_accessor :real, :imag

    def initialize( real, imag )
      @real, @imag = real, imag
    end

    def inspect
      "Hornetseye::Complex(#{@real.inspect},#{@imag.inspect})"
    end

    def to_s
      "Complex(#{@real.to_s},#{@imag.to_s})"
    end

    def store( value )
      @real, @imag = value.real, value.imag
    end

    def coerce( other )
      if other.is_a? Complex
        return other, self
      elsif other.is_a? ::Complex
        return Complex.new( other.real, other.imag ), self
      else
        return Complex.new( other, 0 ), self
      end
    end

    def conj
      Complex.new @real, -@imag
    end

    def abs
      Math.hypot @real, @imag
    end

    def arg
      Math.atan2 @imag, @real
    end

    def polar
      return abs, arg
    end

    def +@
      self
    end

    def -@
      Complex.new -@real, -@imag
    end

    def +( other )
      if other.is_a?( Complex ) or other.is_a?( ::Complex )
        Complex.new @real + other.real, @imag + other.imag
      elsif Complex.generic? other
        Complex.new @real + other, @imag
      else
        x, y = other.coerce self
        x + y
      end
    end

    def -( other )
      if other.is_a?( Complex ) or other.is_a?( ::Complex )
        Complex.new @real - other.real, @imag - other.imag
      elsif Complex.generic? other
        Complex.new @real - other, @imag
      else
        x, y = other.coerce self
        x - y
      end
    end

    def *( other )
      if other.is_a?( Complex ) or other.is_a?( ::Complex )
        Complex.new @real * other.real - @imag * other.imag,
                    @real * other.imag + @imag * other.real
      elsif Complex.generic? other
        Complex.new @real * other, @imag * other
      else
        x, y = other.coerce self
        x * y
      end
    end

    def /( other )
      if other.is_a?( Complex ) or other.is_a?( ::Complex )
        self * other.conj / other.abs2
      elsif Complex.generic? other
        Complex.new @real / other, @imag / other
      else
        x, y = other.coerce self
        x / y
      end
    end

    def **( other )
      if other.is_a?( Complex ) or other.is_a?( ::Complex )
        r, theta = polar
        ore = other.real
        oim = other.imag
        nr = Math.exp ore * Math.log( r ) - oim * theta
        ntheta = theta * ore + oim * Math.log( r )
        Complex.polar nr, ntheta
      elsif Complex.generic? other
        r, theta = polar
        Complex.polar r ** other, theta * other
      else
        x, y = other.coerce self
        x ** y
      end
    end

    def zero?
      @real.zero?.and @imag.zero?
    end

    def nonzero?
      @real.nonzero?.or @imag.nonzero?
    end

    def abs2
      @real * @real + @imag * @imag
    end

    def ==( other )
      if other.is_a?( Complex ) or other.is_a?( ::Complex )
        @real.eq( other.real ).and( @imag.eq( other.imag ) )
      elsif Complex.generic? other
        @real.eq( other ).and( @imag.eq( 0 ) )
      else
        false
      end
    end

    def decompose
      Hornetseye::Sequence[ @real, @imag ]
    end

  end

  class COMPLEX_ < Element

    class << self

      attr_accessor :element_type

      def fetch( ptr )
        construct *ptr.load( self )
      end

      def construct( real, imag )
        if Thread.current[ :function ]
          new Complex.new( real, imag )
        else
          new Kernel::Complex( real, imag )
        end
      end

      def memory
        element_type.memory
      end

      def storage_size
        element_type.storage_size * 2
      end

      def default
        if Thread.current[ :function ]
          Complex.new 0, 0
        else
          Kernel::Complex 0, 0
        end
      end

      def directive
        element_type.directive * 2
      end

      def inspect
        unless element_type.nil?
          { SFLOAT => 'SCOMPLEX',
            DFLOAT => 'DCOMPLEX' }[ element_type ] ||
          "COMPLEX(#{element_type.inspect})"
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
        [ element_type ] * 2
      end

      def scalar
        element_type.float
      end

      def maxint
        Hornetseye::COMPLEX element_type.maxint
      end

      def float
        Hornetseye::COMPLEX element_type.float
      end

      def coercion( other )
        if other < COMPLEX_
          Hornetseye::COMPLEX element_type.coercion( other.element_type )
        elsif other < INT_ or other < FLOAT_
          Hornetseye::COMPLEX element_type.coercion( other )
        else
          super other
        end
      end

      def coerce( other )
        if other < COMPLEX_
          return other, self
        elsif other < INT_ or other < FLOAT_
          return Hornetseye::COMPLEX( other ), self
        else
          super other
        end        
      end

      def ==( other )
        other.is_a? Class and other < COMPLEX_ and
          element_type == other.element_type
      end

      def hash
        [ :COMPLEX_, element_type ].hash
      end

      def eql?( other )
        self == other
      end

      def decompose
        Hornetseye::Sequence( self.class.element_type,
                              2 )[ @value.real, @value.imag ]
      end

    end

    def initialize( value = self.class.default )
      if Thread.current[ :function ].nil? or
        [ value.real, value.imag ].all? { |c| c.is_a? GCCValue }
        @value = value
      else
        real = GCCValue.new Thread.current[ :function ], value.real.to_s
        imag = GCCValue.new Thread.current[ :function ], value.imag.to_s
        @value = Complex.new real, imag
      end
    end

    def dup
      if Thread.current[ :function ]
        real = Thread.current[ :function ].variable self.class.element_type, 'v'
        imag = Thread.current[ :function ].variable self.class.element_type, 'v'
        real.store @value.real
        imag.store @value.imag
        self.class.new Complex.new( real, imag )
      else
        self.class.new get
      end
    end

    def store( value )
      value = value.simplify
      if @value.real.respond_to? :store
        @value.real.store value.get.real
      else
        @value.real = value.get.real
      end
      if @value.imag.respond_to? :store
        @value.imag.store value.get.imag
      else
        @value.imag = value.get.imag
      end
      value
    end

    def values
      [ @value.real, @value.imag ]
    end

    module Match

      def fit( *values )
        if values.all? { |value| value.is_a? Complex or value.is_a? ::Complex or
                                 value.is_a? Float or value.is_a? Integer }
          if values.any? { |value| value.is_a? Complex or value.is_a? ::Complex }
            elements = values.inject( [] ) do |arr,value|
              if value.is_a? Complex or value.is_a? ::Complex
                arr + [ value.real, value.imag ]
              else
                arr + [ value ]
              end
            end
            element_fit = fit *elements
            if element_fit == OBJECT
              super *values
            else
              Hornetseye::COMPLEX element_fit
            end
          else
            super *values
          end
        else
          super *values
        end
      end

      def align( context )
        if self < COMPLEX_
          Hornetseye::COMPLEX element_type.align( context )
        else
          super context
        end
      end

    end

    Node.extend Match

  end

  def COMPLEX( arg )
    retval = Class.new COMPLEX_
    retval.element_type = arg
    retval
  end

  module_function :COMPLEX

  SCOMPLEX = COMPLEX SFLOAT

  DCOMPLEX = COMPLEX DFLOAT

  def SCOMPLEX( value )
    SCOMPLEX.new value
  end

  def DCOMPLEX( value )
    DCOMPLEX.new value
  end

  module_function :SCOMPLEX
  module_function :DCOMPLEX

end

