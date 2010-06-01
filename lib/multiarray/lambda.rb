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

    # Strip of all values.
    #
    # Split up into variables, values, and a term where all values have been
    # replaced with variables.
    #
    # @return [Array<Array,Node>] Returns an array of variables, an array of
    # values, and the term based on variables.
    #
    # @private
    def strip
      vars, values, term = @term.strip
      meta_vars, meta_values, var = @index.strip
      return vars + meta_vars, values + meta_values,
        Lambda.new( var, term.subst( @index => var ) )
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
    # @private
    def lookup( value, stride )
      if value.is_a? Variable
        Lookup.new self, value, stride
      else
        Lambda.new @index, @term.lookup( value, stride )
      end
    end

    def element( i )
      i = Node.match( i ).new i unless i.is_a? Node
      i.size.store @index.size if @index.size.get and i.is_a? Variable
      @term.subst @index => i
    end

  end

end
