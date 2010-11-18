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
 
  # Class representing a compiled function 
  class GCCFunction

    class << self

      # Compile a block of Ruby code if not compiled already and run it
      #
      # @param [Node] block Expression to compile and run.
      #
      # @return [Object] Result returned by the compiled function.
      #
      # @private
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

      # Compile a block of Ruby code if not compiled already
      #
      # @param [String] method_name Unique method name of function.
      # @param [Node] term Stripped expression to compile.
      # @param [Array<Variable>] keys Variables for performing substitutions on
      #        +term+.
      #
      # @return [Object] The return value should be ignored.
      #
      # @private
      def compile( method_name, term, *keys )
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

    # Constructor
    #
    # @param [GCContext] context Context object for compiling function.
    # @param [String] method_name Unique method name.
    # @param [Array<Class>] param_types Native types of parameters.
    #
    # @private
    def initialize( context, method_name, *param_types )
      context.function method_name, *param_types.collect { |t| GCCType.new t }
      @context = context
      @method_name = method_name
      @param_types = param_types
      @indent = 1
      @ids = 0
    end

    # Close the function and compile it
    #
    # @return [GCCFunction] Returns +self+.
    #
    # @private
    def compile
      self << '}'
      @context.compile
      self
    end

    # Create a new identifier unique to this function
    #
    # @param [String] prefix Prefix for constructing the identifier.
    #
    # @return [String] A new identifier.
    #
    # @private
    def id( prefix )
      @ids += 1
      "%s%02d"% [ prefix, @ids ]
    end

    # Create a new C variable of given type
    #
    # @param [Class] typecode Native type of variable.
    # @param [String] prefix Prefix for creating variable name.
    #
    # @return [GCCValue] GCC value object refering to the C variable.
    #
    # @private
    def variable( typecode, prefix )
      retval = GCCValue.new( self, id( prefix ) )
      self << "#{indent}#{GCCType.new( typecode ).identifier} #{retval};\n"
      retval
    end

    # Auxiliary method for code intendation
    #
    # @return [String] String to use for indentation.
    #
    # @private
    def indent
      '  ' * @indent
    end

    # Increase/decrease amount of indentation
    #
    # @param [Integer] offset Offset to add to current amount of indentation.
    #
    # @return [Integer] Resulting amount of indentation.
    #
    # @private
    def indent_offset( offset )
      @indent += offset
    end

    # Retrieve a parameter
    #
    # @param [Integer] i Parameter to retrieve.
    #
    # @return [Node] Object for handling the parameter.
    #
    # @private
    def param( i )
      offset = ( 0 ... i ).inject( 0 ) do |s,idx|
        s + GCCType.new( @param_types[ idx ] ).identifiers.size
      end
      args = ( 0 ... GCCType.new( @param_types[ i ] ).identifiers.size ).
        collect { |idx| GCCValue.new self, "param#{ offset + idx }" }
      @param_types[ i ].construct *args
    end

    # Call the native method
    #
    # @param [Array<Node>] args Arguments of method call.
    #
    # @return The return value of the native method.
    #
    # @private
    def call( *args )
      @context.send @method_name, *args.collect { |v| v.get }
    end

    # Add return instruction to native method
    #
    # @param [Object,NilClass] value Return value or +nil+.
    #
    # @return [GCCFunction] Returns +self+.
    #
    # @private
    def insn_return( value = nil )
      self << "#{indent}return#{ value ? ' ' + value.get.to_s : '' };\n"
    end

    # Add instructions to C function
    #
    # @param [String] str C code fragment.
    #
    # @return [GCCFunction] Returns +self+.
    #
    # @private
    def <<( str )
      @context << str
      self
    end

  end
  
end
