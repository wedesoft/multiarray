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

  class Lambda < Node

    def initialize( index, term )
      @index = index
      @term = term
    end

    # Get unique descriptor of this object
    #
    # @param [Hash] hash Labels for any variables.
    #
    # @return [String] Descriptor of this object,
    #
    # @private
    def descriptor( hash )
      hash = hash.merge @index => ( ( hash.values.max || 0 ) + 1 )
      "Lambda(#{@index.descriptor( hash )},#{@term.descriptor( hash )})"
    end

    def array_type
      Hornetseye::Sequence @term.array_type, @index.size.get
    end

    def variables
      @term.variables - @index.variables + @index.meta.variables
    end

    # Strip of all values
    #
    # Split up into variables, values, and a term where all values have been
    # replaced with variables.
    #
    # @return [Array<Array,Node>] Returns an array of variables, an array of
    # values, and the term based on variables.
    #
    # @private
    def strip
      meta_vars, meta_values, var = @index.strip
      vars, values, term = @term.subst( @index => var ).strip
      return vars + meta_vars, values + meta_values, Lambda.new( var, term )
    end

    def subst( hash )
      subst_var = @index.subst hash
      Lambda.new subst_var, @term.subst( @index => subst_var ).subst( hash )
    end

    def store( value )
      shape.last.times do |i|
        node = value.dimension == 0 ? value : value.element( INT.new( i ) )
        element( INT.new( i ) ).store node
      end
      value
    end

    # Lookup element of an array
    #
    # @param [Node] value Index of element.
    # @param [Node] stride Stride for iterating over elements.
    #
    # @return [Lookup,Lambda] Result of lookup.
    #
    # @private
    def lookup( value, stride )
      if value.is_a? Variable
        Lookup.new self, value, stride
      else
        Lambda.new @index, @term.lookup( value, stride )
      end
    end

    def skip( index, start )
      Lambda.new @index, @term.skip( index, start )
    end

    # Get element of this term
    # Pass +i+ as argument to this lambda object.
    #
    # @param [Integer,Node] i Index of desired element.
    #
    # @return [Node,Object] Result of inserting +i+ for lambda argument.
    def element( i )
      unless i.is_a? Node
        unless ( 0 ... shape.last ).member? i
          raise "Index must be in 0 ... #{shape.last} (was #{i})"
        end
        i = Node.match( i ).new i
      end
      i.size.store @index.size if @index.size.get and i.is_a? Variable
      @term.subst @index => i
    end

    def slice( start, length )
      unless start.is_a?( Node ) or length.is_a?( Node )
        if start < 0 or start + length > shape.last
          raise "Range must be in 0 ... #{shape.last} " +
                "(was #{start} ... #{start + length})"
        end
      end
      start = Node.match( start ).new start unless start.is_a? Node
      length = Node.match( length ).new length unless length.is_a? Node
      index = Variable.new Hornetseye::INDEX( length )
      Lambda.new( index, @term.subst( @index => index ).
                         skip( index, start ) ).unroll
    end

    def compilable?
      @term.compilable?
    end

    def finalised?
      @term.finalised?
    end

  end

end
