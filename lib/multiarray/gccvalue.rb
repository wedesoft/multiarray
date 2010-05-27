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

module Hornetseye
  
  class GCCValue

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

    def demand( typecode )
      result = @function.variable( typecode, 'v' ).get
      @function << "#{@function.indent}#{result} = #{self};\n"
      result
    end

    def store( value )
      @function << "#{@function.indent}#{self} = #{value};\n"
      value
    end

    def compilable?
      false
    end

    def load( typecode )
      GCCValue.new @function, "*(#{GCCType.new( typecode ).identifier} *)( #{self} )"
    end

    def save( value )
      @function << "#{@function.indent}*(#{GCCType.new( value.typecode ).identifier} *)( #{self} ) = #{value.get};\n"
    end

    def -@
      GCCValue.new @function, "-( #{self} )"
    end

    def +( other )
      GCCValue.new @function, "( #{self} ) + ( #{other} )"
    end

    def -( other )
      GCCValue.new @function, "( #{self} ) - ( #{other} )"
    end

    def *( other )
      GCCValue.new @function, "( #{self} ) * ( #{other} )"
    end

    def /( other )
      GCCValue.new @function, "( #{self} ) / ( #{other} )"
    end

    def times( &action )
      i = @function.variable INT, 'i'
      @function << "#{@function.indent}for ( #{i.get} = 0; #{i.get} != #{self}; #{i.get}++ ) {\n"
      @function.indent_offset +1
      action.call i.get
      @function.indent_offset -1
      @function << "#{@function.indent}};\n"
    end

  end

end