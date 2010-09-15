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

  class Variable < Node

    # Type information about this variable
    #
    # @return [Class] Returns type information about this variable.
    attr_reader :meta

    def initialize( meta )
      @meta = meta
    end

    # Display string with information about this object
    #
    # @return [String] String with information about this object (e.g.
    #         'Variable(INT)').
    def inspect
      "Variable(#{@meta.inspect})"
    end

    # Get unique descriptor of this object
    #
    # @param [Hash] hash Labels for any variables.
    #
    # @return [String] Descriptor of this object,
    #
    # @private
    def descriptor( hash )
      if hash[ self ]
        "Variable#{hash[ self ]}(#{@meta.descriptor( hash )})"
      else
        "Variable(#{@meta.descriptor( hash )})"
      end
    end

    # Get array size for index variable
    #
    # @return [Node] Get the dimension of the array if this is an index variable.
    def size
      @meta.size
    end

    # Set array size for index variable
    #
    # Set the dimension of the array assuming this is an index variable.
    #
    # @param [Node] value The new size.
    def size=( value )
      @meta.size = value
    end

    # Get type of result of delayed operation
    #
    # @return [Class] Type of result.
    #
    # @private
    def array_type
      @meta.array_type
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
      meta_vars, meta_values, meta_term = @meta.strip
      if meta_vars.empty?
        return [], [], self
      else
        return meta_vars, meta_values, Variable.new( meta_term )
      end
    end

    # Substitute variables
    #
    # Substitute the variables with the values given in the hash.
    #
    # @param [Hash] hash Substitutions to apply.
    #
    # @return [Node] Term with substitutions applied.
    #
    # @private
    def subst( hash )
      if hash[ self ]
        hash[ self ]
      elsif not @meta.variables.empty? and hash[ @meta.variables.to_a.first ]
        Variable.new @meta.subst( hash )
      else
        self
      end
    end

    # Get variables contained in this object
    #
    # @return [Set] Returns +Set[ self ]+.
    #
    # @private
    def variables
      Set[ self ]
    end

    # Lookup element of an array
    #
    # @param [Node] value Index of element.
    # @param [Node] stride Stride for iterating over elements.
    #
    # @private
    def lookup( value, stride )
      Lookup.new self, value, stride
    end

    # Skip elements of an array
    #
    # @param [Variable] index Variable identifying index of array.
    # @param [Node] start Wrapped integer with number of elements to skip.
    #
    # @return [Node] Return variable with offset added or +self+.
    #
    # @private
    def skip( index, start )
      if index == self
        self + start
      else
        self
      end
    end

  end

end
