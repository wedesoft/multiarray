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

  class Lookup < Node

    def initialize( p, index, stride )
      @p, @index, @stride = p, index, stride
    end

    # Get unique descriptor of this object
    #
    # @param [Hash] hash Labels for any variables.
    #
    # @return [String] Descriptor of this object,
    #
    # @private
    def descriptor( hash )
      "Lookup(#{@p.descriptor( hash )},#{@index.descriptor( hash )}," +
        "#{@stride.descriptor( hash )})"
    end

    def array_type
      @p.array_type
    end

    def subst( hash )
      @p.subst( hash ).lookup @index.subst( hash ), @stride.subst( hash )
    end

    def variables
      @p.variables + @index.variables + @stride.variables
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
      vars1, values1, term1 = @p.strip
      vars2, values2, term2 = @stride.strip
      return vars1 + vars2, values1 + values2,
        Lookup.new( term1, @index, term2 )
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
        Lookup.new @p.lookup( value, stride ), @index, @stride
      end
    end

    def skip( index, start )
      if @index == index
        Lookup.new @p.lookup( start, @stride ), @index, @stride
      else
        Lookup.new @p.skip( index, start ), @index, @stride
      end
    end

    def element( i )
      Lookup.new @p.element( i ), @index, @stride
    end

    def slice( start, length )
      Lookup.new @p.slice( start, length ), @index, @stride
    end

  end

end
