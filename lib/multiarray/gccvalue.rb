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

  # Class for generating code handling C values
  # @private
  class GCCValue

    class << self

      # Check compatibility of other type
      #
      # This method checks whether binary operations with the other Ruby object can
      # be performed without requiring coercion.
      #
      # @param [Object] value The other Ruby object.
      #
      # @return [Boolean] Returns +false+ if Ruby object requires coercion.
      #
      # @private
      def generic?( value )
        value.is_a?( GCCValue ) or value.is_a?( Fixnum ) or
          value.is_a?( Float )
      end

      # Meta-programming method used to define unary operations at the beginning
      #
      # @param [Symbol,String] op Name of unary operation.
      # @param [Symbol,String] opcode Name of unary operation in C.
      #
      # @return [Proc] The new method.
      #
      # @private
      def define_unary_op( op, opcode = op )
        define_method( op ) do
          GCCValue.new @function, "#{opcode}( #{self} )"
        end
      end

      # Meta-programming method used to define unary methods at the beginning
      #
      # @param [Symbol,String] op Name of unary method.
      # @param [Symbol,String] opcode Name of unary method in C.
      #
      # @return [Proc] The new method.
      #
      # @private
      def define_unary_method( mod, op, opcode = op )
        mod.module_eval do
          define_method( "#{op}_with_gcc" ) do |a|
            if a.is_a? GCCValue
              GCCValue.new a.function, "#{opcode}( #{a} )"
            else
              send "#{op}_without_gcc", a
            end
          end
          alias_method_chain op, :gcc
          module_function "#{op}_without_gcc"
          module_function op
        end
      end

      # Meta-programming method used to define unary methods at the beginning
      #
      # @param [Symbol,String] op Name of unary method.
      # @param [Symbol,String] opcode Name of unary method in C.
      #
      # @return [Proc] The new method.
      #
      # @private
      def define_binary_op( op, opcode = op )
        define_method( op ) do |other|
          if GCCValue.generic? other
            GCCValue.new @function, "( #{self} ) #{opcode} ( #{other} )"
          else
            x, y = other.coerce self
            x.send op, y
          end
        end
      end

      # Meta-programming method used to define binary methods at the beginning
      #
      # @param [Symbol,String] op Name of binary method.
      # @param [Symbol,String] opcode Name of binary method in C.
      #
      # @return [Proc] The new method.
      #
      # @private
      def define_binary_method( mod, op, opcode = op )
        mod.module_eval do
          define_method( "#{op}_with_gcc" ) do |a,b|
            if a.is_a? GCCValue or b.is_a? GCCValue
              function = a.is_a?( GCCValue ) ? a.function : b.function
              GCCValue.new function, "#{opcode}( #{a}, #{b} )"
            else
              send "#{op}_without_gcc", a, b
            end
          end
          alias_method_chain op, :gcc
          module_function "#{op}_without_gcc"
          module_function op
        end
      end

    end

    # Get current function context
    #
    # @return [GCCFunction] The function this value is part of.
    #
    # @private
    attr_reader :function

    # Constructor for GCC value
    #
    # @param [GCCFunction] function The function context this value is part of.
    # @param [String] descriptor C code to compute this value.
    #
    # @private
    def initialize( function, descriptor ) 
      @function = function
      @descriptor = descriptor
    end

    # Display descriptor of this object
    #
    # @return [String] Returns the descriptor of this object.
    #
    # @private
    def inspect
      @descriptor
    end

    # Get descriptor of this object
    #
    # @return [String] Returns the descriptor of this object.
    #
    # @private
    def to_s
      @descriptor
    end

    # Store new value in this object
    #
    # @param [Object] value The new value.
    #
    # @return [Object] Returns +value+.
    #
    # @private
    def store( value )
      @function << "#{@function.indent}#{self} = #{value};\n"
      value
    end

    # Indicate whether this object can be compiled
    #
    # @return [Boolean] Returns +false+.
    #
    # @private
    def compilable?
      false
    end

    # Add code to read all components of a typed value from memory
    #
    # @return [Array<GCCValue>] An array of objects referencing values in C.
    #
    # @private
    def load( typecode )
      offset = 0
      typecode.typecodes.collect do |t|
        value = GCCValue.new @function,
          "*(#{GCCType.new( t ).identifier} *)( #{self} + #{offset} )"
        offset += t.storage_size
        value
      end
    end

    # Add code to write all components of a typed value to memory
    #
    # @param [Node] value Value to write to memory.
    #
    # @return [Object] The return value should be ignored.
    #
    # @private
    def save( value )
      offset = 0
      value.class.typecodes.zip( value.values ).each do |t,v|
        @function << "#{@function.indent}*(#{GCCType.new( t ).identifier} *)( #{self} + #{offset} ) = #{v};\n"
        offset += t.storage_size
      end
    end

    # Complex conjugate of real value
    #
    # @return [GCCValue] Returns +self+.
    #
    # @private
    def conj
      self
    end

    # Generate code for computing absolute value
    #
    # @return [GCCValue] C value referring to the result.
    #
    # @private
    def abs
      ( self >= 0 ).conditional self, -self
    end

    # Generate code for computing complex argument of real value
    #
    # @return [GCCValue] C value referring to the result.
    #
    # @private
    def arg
      ( self >= 0 ).conditional 0, Math::PI
    end

    # Red colour component of real value
    #
    # @return [GCCValue] Returns +self+.
    #
    # @private
    def r
      self
    end

    # Green colour component of real value
    #
    # @return [GCCValue] Returns +self+.
    #
    # @private
    def g
      self
    end

    # Blue colour component of real value
    #
    # @return [GCCValue] Returns +self+.
    #
    # @private
    def b
      self
    end

    # Real component of real value
    #
    # @return [GCCValue] Returns +self+.
    #
    # @private
    def real
      self
    end

    # Imaginary component of real value
    #
    # @return [Integer] Returns +0+.
    #
    # @private
    def imag
      0
    end

    # Create code for conditional selection of value
    #
    # @param [GCCValue,Object] a First value.
    # @param [GCCValue,Object] b Second value.
    #
    # @return [GCCValue] C value referring to result.
    #
    # @private
    def conditional( a, b )
      GCCValue.new @function, "( #{self} ) ? ( #{a} ) : ( #{b} )"
    end

    # Create code for conditional selection of RGB value
    #
    # @param [GCCValue,Object] a First value.
    # @param [GCCValue,Object] b Second value.
    #
    # @return [GCCValue] C value referring to result.
    #
    # @private
    def conditional_with_rgb( a, b )
      if a.is_a?( RGB ) or b.is_a?( RGB )
        Hornetseye::RGB( conditional( a.r, b.r ), conditional( a.g, b.g ),
                         conditional( a.b, b.b ) )
      else
        conditional_without_rgb a, b
      end
    end

    alias_method_chain :conditional, :rgb

    # Create code for conditional selection of complex value
    #
    # @param [GCCValue,Object] a First value.
    # @param [GCCValue,Object] b Second value.
    #
    # @return [GCCValue] C value referring to result.
    #
    # @private
    def conditional_with_complex( a, b )
      if a.is_a?( InternalComplex ) or b.is_a?( InternalComplex )
        InternalComplex.new conditional( a.real, b.real ),
                            conditional( a.imag, b.imag )
      else
        conditional_without_complex a, b
      end
    end

    alias_method_chain :conditional, :complex

    define_unary_op :not, '!'
    define_unary_op :~
    define_unary_op :-@, :-
    define_binary_op :and, '&&'
    define_binary_op :or, '||'
    define_binary_op :&
    define_binary_op :|
    define_binary_op :^
    define_binary_op :<<
    define_binary_op :>>
    define_binary_op :+
    define_binary_op :-
    define_binary_op :*
    define_binary_op :/
    alias_method :div, :/
    define_binary_op :%
    define_binary_op :eq, :==
    define_binary_op :ne, '!='
    define_binary_op :<
    define_binary_op :<=
    define_binary_op :>
    define_binary_op :>=
    define_unary_method Math, :sqrt
    define_unary_method Math, :log
    define_unary_method Math, :log10
    define_unary_method Math, :exp
    define_unary_method Math, :cos
    define_unary_method Math, :sin
    define_unary_method Math, :tan
    define_unary_method Math, :acos
    define_unary_method Math, :asin
    define_unary_method Math, :atan
    define_unary_method Math, :cosh
    define_unary_method Math, :sinh
    define_unary_method Math, :tanh
    define_unary_method Math, :acosh
    define_unary_method Math, :asinh
    define_unary_method Math, :atanh
    define_binary_method Math, :atan2
    define_binary_method Math, :hypot

    # Generate code for checking whether value is equal to zero
    #
    # @return [GCCValue] C value refering to the result.
    #
    # @private
    def zero?
      GCCValue.new @function, "( #{self} ) == 0"
    end

    # Generate code for checking whether value is not equal to zero
    #
    # @return [GCCValue] C value refering to the result.
    #
    # @private
    def nonzero?
      GCCValue.new @function, "( #{self} ) != 0"
    end

    # Generate code for computing largest integer value not greater than this value
    #
    # @return [GCCValue] C value refering to the result.
    #
    # @private
    def floor
      GCCValue.new @function, "floor( #{self} )"
    end

    # Generate code for computing smallest integer value not less than this value
    #
    # @return [GCCValue] C value refering to the result.
    #
    # @private
    def ceil
      GCCValue.new @function, "ceil( #{self} )"
    end

    # Generate code for rounding to nearest integer
    #
    # @return [GCCValue] C value refering to the result.
    #
    # @private
    def round
      GCCValue.new @function, "round( #{self} )"
    end

    # Generate code for computing exponentiation
    #
    # @param [Object,GCCValue] other Second operand for binary operation.
    #
    # @return [GCCValue] C value refering to the result.
    #
    # @private
    def **( other )
      if GCCValue.generic? other
        GCCValue.new @function, "pow( #{self}, #{other} )"
      else
        x, y = other.coerce self
        x ** y
      end
    end

    # Generate code for selecting larger value
    #
    # @param [Object,GCCValue] other Second operand for binary operation.
    #
    # @return [GCCValue] C value refering to the result.
    #
    # @private
    def major( other )
      GCCValue.new @function,
        "( ( #{self} ) >= ( #{other} ) ) ? ( #{self} ) : ( #{other} )"
    end

    # Generate code for selecting smaller value
    #
    # @param [Object,GCCValue] other Second operand for binary operation.
    #
    # @return [GCCValue] C value refering to the result.
    #
    # @private
    def minor( other )
      GCCValue.new @function,
        "( ( #{self} ) <= ( #{other} ) ) ? ( #{self} ) : ( #{other} )"
    end

    # Generate a +for+ loop in C
    #
    # @param [Proc] action Code for generating loop body.
    #
    # @return [GCCValue] Returns +self+.
    #
    # @private
    def times( &action )
      i = @function.variable INT, 'i'
      @function << "#{@function.indent}for ( #{i} = 0; " +
                   "#{i} != #{self}; #{i}++ ) {\n"
      @function.indent_offset +1
      action.call i
      @function.indent_offset -1
      @function << "#{@function.indent}};\n"
      self
    end

    # Generate a +for+ loop in C
    #
    # @param [GCCValue,Object] other Upper limit for loop.
    # @param [Proc] action Code for generating loop body.
    #
    # @return [GCCValue] Returns +self+.
    #
    # @private
    def upto( other, &action )
      i = @function.variable INT, 'i'
      @function << "#{@function.indent}for ( #{i} = #{self}; " +
                   "#{i} != #{ other + 1 }; #{i}++ ) {\n"
      @function.indent_offset +1
      action.call i
      @function.indent_offset -1
      @function << "#{@function.indent}};\n"
      self
    end

    # Type coercion for GCC values
    #
    # @param [Object] other Other value to coerce with.
    #
    # @return [Array<GCCValue>] Result of coercion.
    #
    # @private
    def coerce( other )
      if other.is_a? GCCValue
        return other, self
      else
        return GCCValue.new( @function, "( #{other} )" ), self
      end
    end

  end

end
