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
  
  class GCCFunction

    class << self

      def run( block )
        keys, values, term = block.strip
        labels = Hash[ *keys.zip( ( 0 ... keys.size ).to_a ).flatten ]
        retval = block.pointer_type.new
        retval_keys, retval_values, retval_term = retval.strip
        method_name = '_' + term.descriptor( labels ).
                      tr( '(),+\-*/.@?~&|^<>',
                          '0123\456789ABCDEF' )
        unless GCCCache.respond_to? method_name
          GCCContext.build do |context|
            function = new context, method_name,
                           *( retval_keys + keys ).collect { |var| var.meta }
            term_subst = ( 0 ... keys.size ).collect do |i|
              { keys[i] => function.param( i + retval_keys.size ) }
            end.inject( {} ) { |a,b| a.merge b }
            retval_subst = ( 0 ... retval_keys.size ).collect do |i|
              { retval_keys[ i ] => function.param( i ) }
            end.inject( {} ) { |a,b| a.merge b }
            Thread.current[ :function ] = function
            Hornetseye::lazy do
              retval_term.subst( retval_subst ).store term.subst( term_subst )
            end
            Thread.current[ :function ] = nil
            function.insn_return
            function.compile
          end
        end
        args = ( retval_values + values ).collect { |arg| arg.get }
        GCCCache.send method_name, *args
        retval.simplify
      end

    end

    def initialize( context, method_name, *param_types )
      context.function method_name, *param_types.collect { |t| GCCType.new t }
      @context = context
      @method_name = method_name
      @param_types = param_types
      @indent = 1
      @ids = 0
    end

    def compile
      self << '}'
      @context.compile
      self
    end

    def id( prefix )
      @ids += 1
      "%s%02d"% [ prefix, @ids ]
    end

    def variable( typecode, prefix )
      if typecode == INTRGB
        r = GCCValue.new( self, id( prefix ) )
        g = GCCValue.new( self, id( prefix ) )
        b = GCCValue.new( self, id( prefix ) )
        self << "#{indent}#{GCCType.new( INT ).identifier} #{r};\n"
        self << "#{indent}#{GCCType.new( INT ).identifier} #{g};\n"
        self << "#{indent}#{GCCType.new( INT ).identifier} #{b};\n"
        INTRGB.new RGB.new( r, g, b )
      else
        retval = typecode.new GCCValue.new( self, id( prefix ) )
        self << "#{indent}#{GCCType.new( typecode ).identifier} #{retval.get};\n"
        retval
      end
    end

    def indent
      '  ' * @indent
    end

    def indent_offset( offset )
      @indent += offset
    end

    def param( i )
      @param_types[ i ].new GCCValue.new( self, "param#{i}" )
    end

    def call( *args )
      @context.send @method_name, *args.collect { |v| v.get }
    end

    def insn_return( value = nil )
      self << "#{indent}return#{ value ? ' ' + value.get.to_s : '' };\n"
    end

    def <<( str )
      @context << str
      self
    end

  end
  
end
