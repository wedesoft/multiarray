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
  
  class GCCValue

    class << self

      # Check compatibility of other type.
      #
      # This method checks whether binary operations with the other Ruby object can
      # be performed without requiring coercion.
      #
      # @param [Object] value The other Ruby object.
      #
      # @return [FalseClass,TrueClass] Returns +false+ if Ruby object requires
      #         coercion.
      def generic?( value )
        value.is_a?( GCCValue ) or value.is_a?( Fixnum ) or
          value.is_a?( Float )
      end

      def define_unary_op( op, opcode = op )
        define_method( op ) do
          GCCValue.new @function, "#{opcode}( #{self} )"
        end
      end

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

    attr_reader :function

    def initialize( function, descriptor ) 
      @function = function
      @descriptor = descriptor
    end

    # Display descriptor of this object
    #
    # @return [String] Returns the descriptor of this object.
    def inspect
      @descriptor
    end

    # Get descriptor of this object
    #
    # @return [String] Returns the descriptor of this object.
    def to_s
      @descriptor
    end

    def store( value )
      @function << "#{@function.indent}#{self} = #{value};\n"
      value
    end

    def compilable?
      false
    end

    def load( typecode )
      offset = 0
      typecode.typecodes.collect do |t|
        value = GCCValue.new @function,
          "*(#{GCCType.new( t ).identifier} *)( #{self} + #{offset} )"
        offset += t.storage_size
        value
      end
    end

    def save( value )
      offset = 0
      value.class.typecodes.zip( value.values ).each do |t,v|
        @function << "#{@function.indent}*(#{GCCType.new( t ).identifier} *)( #{self} + #{offset} ) = #{v};\n"
        offset += t.storage_size
      end
    end

    def conj
      self
    end

    def abs
      ( self >= 0 ).conditional self, -self
    end

    def arg
      ( self >= 0 ).conditional 0, Math::PI
    end

    def r
      self
    end

    def g
      self
    end

    def b
      self
    end

    def real
      self
    end

    def imag
      0
    end

    def conditional( a, b )
      GCCValue.new @function, "( #{self} ) ? ( #{a} ) : ( #{b} )"
    end

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
    define_binary_op :%
    define_binary_op :eq, :==
    define_binary_op :ne, '!='
    define_binary_op :<
    define_binary_op :<=
    define_binary_op :>
    define_binary_op :>=
    define_unary_method Math, :sqrt
    define_unary_method Math, :log
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
    define_binary_method Math, :atan2
    define_binary_method Math, :hypot

    def zero?
      GCCValue.new @function, "( #{self} ) == 0"
    end

    def nonzero?
      GCCValue.new @function, "( #{self} ) != 0"
    end

    def floor
      GCCValue.new @function, "floor( #{self} )"
    end

    def ceil
      GCCValue.new @function, "ceil( #{self} )"
    end

    def round
      GCCValue.new @function, "round( #{self} )"
    end

    def **( other )
      if GCCValue.generic? other
        GCCValue.new @function, "pow( #{self}, #{other} )"
      else
        x, y = other.coerce self
        x ** y
      end
    end

    def major( other )
      GCCValue.new @function,
        "( ( #{self} ) >= ( #{other} ) ) ? ( #{self} ) : ( #{other} )"
    end

    def minor( other )
      GCCValue.new @function,
        "( ( #{self} ) <= ( #{other} ) ) ? ( #{self} ) : ( #{other} )"
    end

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

    def coerce( other )
      if other.is_a? GCCValue
        return other, self
      else
        return GCCValue.new( @function, "( #{other} )" ), self
      end
    end

  end

end
