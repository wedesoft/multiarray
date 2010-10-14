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

  class InternalComplex

    class << self

      # Check compatibility of other type.
      #
      # This method checks whether binary operations with the other Ruby object can
      # be performed without requiring coercion.
      #
      # @param [Object] value The other Ruby object.
      #
      # @return [Boolean] Returns +false+ if Ruby object requires
      #         coercion.
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

    # Return string with information about this object.
    #
    # @return [String] Returns a string (e.g. "InternalComplex(1,2)").
    def inspect
      "InternalComplex(#{@real.inspect},#{@imag.inspect})"
    end

    # Return string with information about this object.
    #
    # @return [String] Returns a string (e.g. "InternalComplex(1,2)").
    def to_s
      "InternalComplex(#{@real.to_s},#{@imag.to_s})"
    end

    # Store other value in this object
    #
    # @param [Object] value New value for this object.
    #
    # @return [Object] Returns +value+.
    #
    # @private
    def store( value )
      @real, @imag = value.real, value.imag
    end

    def coerce( other )
      if other.is_a? InternalComplex
        return other, self
      elsif other.is_a? Complex
        return InternalComplex.new( other.real, other.imag ), self
      else
        return InternalComplex.new( other, 0 ), self
      end
    end

    def conj
      InternalComplex.new @real, -@imag
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
      InternalComplex.new -@real, -@imag
    end

    def +( other )
      if other.is_a?( InternalComplex ) or other.is_a?( Complex )
        InternalComplex.new @real + other.real, @imag + other.imag
      elsif InternalComplex.generic? other
        InternalComplex.new @real + other, @imag
      else
        x, y = other.coerce self
        x + y
      end
    end

    def -( other )
      if other.is_a?( InternalComplex ) or other.is_a?( Complex )
        InternalComplex.new @real - other.real, @imag - other.imag
      elsif InternalComplex.generic? other
        InternalComplex.new @real - other, @imag
      else
        x, y = other.coerce self
        x - y
      end
    end

    def *( other )
      if other.is_a?( InternalComplex ) or other.is_a?( Complex )
        InternalComplex.new @real * other.real - @imag * other.imag,
                    @real * other.imag + @imag * other.real
      elsif InternalComplex.generic? other
        InternalComplex.new @real * other, @imag * other
      else
        x, y = other.coerce self
        x * y
      end
    end

    def /( other )
      if other.is_a?( InternalComplex ) or other.is_a?( Complex )
        self * other.conj / other.abs2
      elsif InternalComplex.generic? other
        InternalComplex.new @real / other, @imag / other
      else
        x, y = other.coerce self
        x / y
      end
    end

    def **( other )
      if other.is_a?( InternalComplex ) or other.is_a?( Complex )
        r, theta = polar
        ore = other.real
        oim = other.imag
        nr = Math.exp ore * Math.log( r ) - oim * theta
        ntheta = theta * ore + oim * Math.log( r )
        InternalComplex.polar nr, ntheta
      elsif InternalComplex.generic? other
        r, theta = polar
        InternalComplex.polar r ** other, theta * other
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

    # Test on equality
    #
    # @param [Object] other Object to compare with.
    #
    # @return [Boolean] Returns boolean indicating whether objects are
    #         equal or not.
    def ==( other )
      if other.is_a?( InternalComplex ) or other.is_a?( Complex )
        @real.eq( other.real ).and( @imag.eq( other.imag ) )
      elsif InternalComplex.generic? other
        @real.eq( other ).and( @imag.eq( 0 ) )
      else
        false
      end
    end

    # Decompose complex number
    #
    # This method decomposes the complex number into an array.
    #
    # @return [Node] Returns an array with the real and imaginary component as
    #         elements.
    def decompose( i )
      [ @real, @imag ][ i ]
    end

  end

end

module Math

  def sqrt_with_internalcomplex( z )
    if z.is_a? Hornetseye::InternalComplex
      real = sqrt( ( z.abs + z.real ) / 2 )
      imag = ( z.imag < 0 ).conditional -sqrt( ( z.abs - z.real ) / 2 ),
                                        sqrt( ( z.abs - z.real ) / 2 )
      Hornetseye::InternalComplex.new real, imag
    else
      sqrt_without_internalcomplex z
    end
  end

  alias_method_chain :sqrt, :internalcomplex
  module_function :sqrt_without_internalcomplex
  module_function :sqrt

  def exp_with_internalcomplex( z )
    if z.is_a? Hornetseye::InternalComplex
      real = exp( z.real ) * cos( z.imag )
      imag = exp( z.real ) * sin( z.imag )
      Hornetseye::InternalComplex.new real, imag
    else
      exp_without_internalcomplex z
    end
  end

  alias_method_chain :exp, :internalcomplex
  module_function :exp_without_internalcomplex
  module_function :exp

  def cos_with_internalcomplex( z )
    if z.is_a? Hornetseye::InternalComplex
      real = cos( z.real ) * cosh( z.imag )
      imag = -sin( z.real ) * sinh( z.imag )
      Hornetseye::InternalComplex.new real, imag
    else
      cos_without_internalcomplex z
    end
  end

  alias_method_chain :cos, :internalcomplex
  module_function :cos_without_internalcomplex
  module_function :cos

  def sin_with_internalcomplex( z )
    if z.is_a? Hornetseye::InternalComplex
      real = sin( z.real ) * cosh( z.imag )
      imag = cos( z.real ) * sinh( z.imag )
      Hornetseye::InternalComplex.new real, imag
    else
      sin_without_internalcomplex z
    end
  end

  alias_method_chain :sin, :internalcomplex
  module_function :sin_without_internalcomplex
  module_function :sin

  def tan_with_internalcomplex( z )
    if z.is_a? Hornetseye::InternalComplex
      sin( z ) / cos( z )
    else
      tan_without_internalcomplex z
    end
  end

  alias_method_chain :tan, :internalcomplex
  module_function :tan_without_internalcomplex
  module_function :tan

  def cosh_with_internalcomplex( z )
    if z.is_a? Hornetseye::InternalComplex
      real = cosh( z.real ) * cos( z.imag )
      imag = sinh( z.real ) * sin( z.imag )
      Hornetseye::InternalComplex.new real, imag
    else
      cosh_without_internalcomplex z
    end
  end

  alias_method_chain :cosh, :internalcomplex
  module_function :cosh_without_internalcomplex
  module_function :cosh

  def sinh_with_internalcomplex( z )
    if z.is_a? Hornetseye::InternalComplex
      real = sinh( z.real ) * cos( z.imag )
      imag = cosh( z.real ) * sin( z.imag )
      Hornetseye::InternalComplex.new real, imag
    else
      sinh_without_internalcomplex z
    end
  end

  alias_method_chain :sinh, :internalcomplex
  module_function :sinh_without_internalcomplex
  module_function :sinh

  def tanh_with_internalcomplex( z )
    if z.is_a? Hornetseye::InternalComplex
      sinh( z ) / cosh( z )
    else
      tanh_without_internalcomplex z
    end
  end

  alias_method_chain :tanh, :internalcomplex
  module_function :tanh_without_internalcomplex
  module_function :tanh

  def log_with_internalcomplex( z )
    if z.is_a? Hornetseye::InternalComplex
      r, theta = z.polar
      Hornetseye::InternalComplex.new log( r.abs ), theta
    else
      log_without_internalcomplex z
    end
  end

  alias_method_chain :log, :internalcomplex
  module_function :log_without_internalcomplex
  module_function :log

  def log10_with_internalcomplex( z )
    if z.is_a? Hornetseye::InternalComplex
      log( z ) / log( 10 )
    else
      log10_without_internalcomplex z
    end
  end

  alias_method_chain :log10, :internalcomplex
  module_function :log10_without_internalcomplex
  module_function :log10

  def acos_with_internalcomplex( z )
    if z.is_a? Hornetseye::InternalComplex
      -1.0.im * log( z + 1.0.im * sqrt( 1.0 - z * z ) )
    else
      acos_without_internalcomplex z
    end
  end

  alias_method_chain :acos, :internalcomplex
  module_function :acos_without_internalcomplex
  module_function :acos

  def asin_with_internalcomplex( z )
    if z.is_a? Hornetseye::InternalComplex
      -1.0.im * log( 1.0.im * z + sqrt( 1.0 - z * z ) )
    else
      asin_without_internalcomplex z
    end
  end

  alias_method_chain :asin, :internalcomplex
  module_function :asin_without_internalcomplex
  module_function :asin

  def atan_with_internalcomplex( z )
    if z.is_a? Hornetseye::InternalComplex
      1.0.im * log( ( 1.0.im + z ) / ( 1.0.im - z ) ) / 2.0
    else
      atan_without_internalcomplex z
    end
  end

  alias_method_chain :atan, :internalcomplex
  module_function :atan_without_internalcomplex
  module_function :atan

  def acosh_with_internalcomplex( z )
    if z.is_a? Hornetseye::InternalComplex
      log( z + sqrt( z * z - 1.0 ) )
    else
      acosh_without_internalcomplex z
    end
  end

  alias_method_chain :acosh, :internalcomplex
  module_function :acosh_without_internalcomplex
  module_function :acosh

  def asinh_with_internalcomplex( z )
    if z.is_a? Hornetseye::InternalComplex
      log( z + sqrt( 1.0 + z * z ) )
    else
      asinh_without_internalcomplex z
    end
  end

  alias_method_chain :asinh, :internalcomplex
  module_function :asinh_without_internalcomplex
  module_function :asinh

  def atanh_with_internalcomplex( z )
    if z.is_a? Hornetseye::InternalComplex
      log( ( 1.0 + z ) / ( 1.0 - z ) ) / 2.0
    else
      atanh_without_internalcomplex z
    end
  end

  alias_method_chain :atanh, :internalcomplex
  module_function :atanh_without_internalcomplex
  module_function :atanh

  def atan2_with_internalcomplex( y, x )
    if [ x, y ].any? { |v| v.is_a? Hornetseye::InternalComplex }
      -1.0.im * log( ( x + 1.0.im * y ) / sqrt( x * x + y * y ) )
    else
      atan2_without_internalcomplex y, x
    end
  end

  alias_method_chain :atan2, :internalcomplex
  module_function :atan2_without_internalcomplex
  module_function :atan2

end

module Hornetseye

  class COMPLEX_ < Composite

    class << self

      # Set base class attribute
      #
      # Sets number of elements to two.
      def inherited( subclass )
        subclass.num_elements = 2
      end

      # Construct new object from arguments
      #
      # @param [Object] real Real component of complex number.
      # @param [Object] imag Imaginary component of complex number.
      #
      # @return [Complex,InternalComplex] New complex number object.
      #
      # @private
      def construct( real, imag )
        if Thread.current[ :function ]
          new InternalComplex.new( real, imag )
        else
          new Complex( real, imag )
        end
      end

      # Get default value for elements of this type
      #
      # @return [Object,InternalComplex] Returns complex number object with zero real
      #         and imaginary component.
      #
      # @private
      def default
        if Thread.current[ :function ]
          InternalComplex.new 0, 0
        else
          Complex 0, 0
        end
      end

      # Display information about this class
      #
      # @return [String] Returns string with information about this class (e.g.
      #         "SCOMPLEX").
      def inspect
        unless element_type.nil?
          { SFLOAT => 'SCOMPLEX',
            DFLOAT => 'DCOMPLEX' }[ element_type ] ||
          "COMPLEX(#{element_type.inspect})"
        else
          super
        end
      end

      # Get corresponding maximal integer type
      #
      # @return [Class] Corresponding type based on integers.
      #
      # @private
      def maxint
        Hornetseye::COMPLEX element_type.maxint
      end

      # Convert to type based on floating point numbers
      #
      # @return [Class] Corresponding type based on floating point numbers.
      #
      # @private
      def float
        Hornetseye::COMPLEX element_type.float
      end

      # Compute balanced type for binary operation
      #
      # @param [Class] other Other native datatype to coerce with.
      #
      # @return [Class] Result of coercion.
      #
      # @private
      def coercion( other )
        if other < COMPLEX_
          Hornetseye::COMPLEX element_type.coercion( other.element_type )
        elsif other < INT_ or other < FLOAT_
          Hornetseye::COMPLEX element_type.coercion( other )
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
        if other < COMPLEX_
          return other, self
        elsif other < INT_ or other < FLOAT_
          return Hornetseye::COMPLEX( other ), self
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
        other.is_a? Class and other < COMPLEX_ and
          element_type == other.element_type
      end

      # Compute hash value for this class.
      #
      # @return [Fixnum] Hash value
      #
      # @private
      def hash
        [ :COMPLEX_, element_type ].hash
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

    end

    def initialize( value = self.class.default )
      if Thread.current[ :function ].nil? or
        [ value.real, value.imag ].all? { |c| c.is_a? GCCValue }
        @value = value
      else
        real = GCCValue.new Thread.current[ :function ], value.real.to_s
        imag = GCCValue.new Thread.current[ :function ], value.imag.to_s
        @value = InternalComplex.new real, imag
      end
    end

    # Duplicate object
    #
    # @return [COMPLEX_] Duplicate of +self+.
    def dup
      if Thread.current[ :function ]
        real = Thread.current[ :function ].variable self.class.element_type, 'v'
        imag = Thread.current[ :function ].variable self.class.element_type, 'v'
        real.store @value.real
        imag.store @value.imag
        self.class.new InternalComplex.new( real, imag )
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

    # Get array with components of this value
    #
    # @return [Array<Object>] Returns array with real and imaginary component as
    #         elements.
    #
    # @private
    def values
      [ @value.real, @value.imag ]
    end

    module Match

      # Method for matching elements of type COMPLEX_
      #
      # @param [Array<Object>] *values Values to find matching native element
      #        type for.
      #
      # @return [Class] Native type fitting all values.
      #
      # @see COMPLEX_
      #
      # @private
      def fit( *values )
        if values.all? { |value| value.is_a? InternalComplex or value.is_a? Complex or
                                 value.is_a? Float or value.is_a? Integer }
          if values.any? { |value| value.is_a? InternalComplex or value.is_a? Complex }
            elements = values.inject( [] ) do |arr,value|
              if value.is_a? InternalComplex or value.is_a? Complex
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

      # Perform type alignment
      #
      # Align this type to another. This is used to prefer single-precision
      # floating point in certain cases.
      #
      # @param [Class] context Other type to align with.
      #
      # @private
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

  module Operations

    define_unary_op :real, :scalar
    define_unary_op :imag, :scalar

    def real_with_decompose
      if typecode == OBJECT or is_a?( Variable )
        real_without_decompose
      elsif typecode < COMPLEX_
        decompose 0
      else
        self
      end
    end

    alias_method_chain :real, :decompose

    def real=( value )
      if typecode < COMPLEX_
        decompose( 0 )[] = value
      elsif typecode == OBJECT
        self[] = Hornetseye::lazy do
          value + imag * Complex::I
        end
      else
        self[] = value
      end
    end

    def imag_with_decompose
      if typecode == OBJECT or is_a?( Variable )
        imag_without_decompose
      elsif typecode < COMPLEX_
        decompose 1
      else
        Hornetseye::lazy( *shape ) { typecode.new( 0 ) }
      end
    end

    alias_method_chain :imag, :decompose

    def imag=( value )
      if typecode < COMPLEX_
        decompose( 1 )[] = value
      elsif typecode == OBJECT
        self[] = Hornetseye::lazy do
          real + value * Complex::I
        end
      else
        raise "Cannot assign imaginary values to object of type #{array_type.inspect}"
      end
    end

  end

  def COMPLEX( arg )
    retval = Class.new COMPLEX_
    retval.element_type = arg
    retval
  end

  module_function :COMPLEX

  SCOMPLEX = COMPLEX SFLOAT

  DCOMPLEX = COMPLEX DFLOAT

  # Shortcut for constructor
  #
  # The method calls +SCOMPLEX.new+.
  #
  # @param [Complex] value Complex value.
  #
  # @return [SCOMPLEX] The wrapped Complex value.
  #
  # @private
  def SCOMPLEX( value )
    SCOMPLEX.new value
  end

  # Shortcut for constructor
  #
  # The method calls +DCOMPLEX.new+.
  #
  # @param [Complex] value Complex value.
  #
  # @return [DCOMPLEX] The wrapped Complex value.
  #
  # @private
  def DCOMPLEX( value )
    DCOMPLEX.new value
  end

  module_function :SCOMPLEX
  module_function :DCOMPLEX

end

