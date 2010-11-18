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

    @@mutex = Mutex.new

    class << self

      def run( block )
        keys, values, term = block.strip
        labels = Hash[ *keys.zip( ( 0 ... keys.size ).to_a ).flatten ]
        method_name = ( '_' + term.descriptor( labels ) ).
                            tr( '(),+\-*/%.@?~&|^<=>',
                                '0123\456789ABCDEFGH' )
        compile method_name, term, *keys
        args = values.collect { |arg| arg.values }.flatten
        GCCCache.send method_name, *args
      end

      # @see run
      def compile( method_name, term, *keys )
        @@mutex.synchronize do
          unless GCCCache.respond_to? method_name
            GCCContext.build do |context|
              function = GCCFunction.new context, method_name,
                                         *keys.collect { |var| var.meta }
              Thread.current[ :function ] = function
              term_subst = ( 0 ... keys.size ).collect do |i|
                { keys[i] => function.param( i ) }
              end.inject( {} ) { |a,b| a.merge b }
              Hornetseye::lazy do
                term.subst( term_subst ).demand
              end
              Thread.current[ :function ] = nil
              function.insn_return
              function.compile
            end
          end
        end
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
      retval = GCCValue.new( self, id( prefix ) )
      self << "#{indent}#{GCCType.new( typecode ).identifier} #{retval};\n"
      retval
    end

    def indent
      '  ' * @indent
    end

    def indent_offset( offset )
      @indent += offset
    end

    def param( i )
      offset = ( 0 ... i ).inject( 0 ) do |s,idx|
        s + GCCType.new( @param_types[ idx ] ).identifiers.size
      end
      args = ( 0 ... GCCType.new( @param_types[ i ] ).identifiers.size ).
        collect { |idx| GCCValue.new self, "param#{ offset + idx }" }
      @param_types[ i ].construct *args
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
