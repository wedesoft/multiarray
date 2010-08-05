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

      def generic?( value )
        value.is_a?( GCCValue ) or value.is_a?( Fixnum ) or
          value.is_a?( Float )
      end

      def define_unary_op( op, opcode = op )
        define_method( op ) do
          GCCValue.new @function, "#{opcode}( #{self} )"
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

    end

    def initialize( function, descriptor ) 
      @function = function
      @descriptor = descriptor
    end

    def inspect
      @descriptor
    end

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
          "*(#{GCCType.new( t ).identifiers.first} *)( #{self} + #{offset} )" # !!!
        offset += t.storage_size
        value
      end
    end

    def save( value )
      offset = 0
      value.class.typecodes.zip( value.values ).each do |t,v|
        @function << "#{@function.indent}*(#{GCCType.new( t ).identifiers.first} *)( #{self} + #{offset} ) = #{v};\n" # !!!
        offset += t.storage_size
      end
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

    def eq( other )
      GCCValue.new @function, "( #{self} ) == ( #{other} )"
    end

    def ne( other )
      GCCValue.new @function, "( #{self} ) != ( #{other} )"
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

    def major( other )
      GCCValue.new @function,
        "( ( #{self} ) >= ( #{other} ) ) ? ( #{self} ) : ( #{other} )"
    end

    def minor( other )
      GCCValue.new @function,
        "( ( #{self} ) <= ( #{other} ) ) ? ( #{self} ) : ( #{other} )"
    end

    def zero?
      GCCValue.new @function, "( #{self} ) == 0"
    end

    def nonzero?
      GCCValue.new @function, "( #{self} ) != 0"
    end

    def times( &action )
      i = @function.variable INT, 'i'
      @function << "#{@function.indent}for ( #{i.get} = 0; " +
                   "#{i.get} != #{self}; #{i.get}++ ) {\n"
      @function.indent_offset +1
      action.call i.get
      @function.indent_offset -1
      @function << "#{@function.indent}};\n"
      self
    end

    def upto( other, &action )
      i = @function.variable INT, 'i'
      @function << "#{@function.indent}for ( #{i.get} = #{self}; " +
                   "#{i.get} != #{ other + 1 }; #{i.get}++ ) {\n"
      @function.indent_offset +1
      action.call i.get
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
