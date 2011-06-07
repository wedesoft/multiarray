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
      # @param [Array<Variable>] keys Variables for performing substitutions on +term+.
      #
      # @return [Object] The return value should be ignored.
      #
      # @private
      def compile( method_name, term, *keys )
        unless GCCCache.respond_to? method_name
          GCCContext.build do |context|
            function = GCCFunction.new context, method_name,
                                       *keys.collect { |var| var.meta }
            Thread.current[:function] = function
            term_subst = Hash[ *keys.zip(function.params).flatten ]
            Hornetseye::lazy { term.subst(term_subst).demand }
            Thread.current[:function] = nil
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

    # Retrieve all parameters
    #
    # @return [Array<Node>] Objects for handling the parameters.
    #
    # @private
    def params
      idx = 0
      @param_types.collect do |param_type|
        args = GCCType.new( param_type ).identifiers.collect do
          arg = GCCValue.new self, "param#{idx}"
          idx += 1
          arg
        end
        param_type.construct *args
      end
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

class Proc

  # Overloaded while loop for handling compilation
  #
  # @param [Proc] action The loop body
  #
  # @return [NilClass] Returns +nil+.
  #
  # @private
  def while_with_gcc( &action )
    function = Thread.current[ :function ]
    if function
      function << "#{function.indent}while ( 1 ) {\n"
      function.indent_offset +1
      function << "#{function.indent}if ( !( #{call.get}) ) break;\n"
      action.call
      function.indent_offset -1
      function << "#{function.indent}}\n"
      nil
    else
      while_without_gcc &action
    end
  end

  alias_method_chain :while, :gcc

end

