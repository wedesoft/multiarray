# multiarray - Lazy multi-dimensional arrays for Ruby
# Copyright (C) 2010, 2011 Jan Wedekind
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

  # Ruby array supporting array views
  #
  # @see Malloc
  class List

    # Initialise array
    #
    # @param [Integer] n Number of elements.
    # @option options [Array] :array ([ nil ] * n) Existing Ruby array to create an
    #         array view.
    # @option options [Integer] :offset (0) Offset for array view.
    def initialize( n, options = {} )
      @array = options[ :array ] || [ nil ] * n
      @offset = options[ :offset ] || 0
    end

    # Display information about this object
    #
    # @return [String] String with information about this object (e.g. "List(5)").
    def inspect
      "List(#{@array.size - @offset})"
    end

    # Display information about this object
    #
    # @return [String] String with information about this object (e.g. "List(5)").
    def to_s
      inspect
    end

    # Create array view with specified offset
    #
    # @param [Integer] offset Offset for array view.
    #
    # @return [List] The resulting array view.
    def +( offset )
      List.new 0, :array => @array, :offset => @offset + offset
    end

    # Retrieve value of specified typecode
    #
    # @param [Class] typecode The type of the value.
    #
    # @return [Object] The referenced value.
    #
    # @private
    def load( typecode )
      @array[ @offset ]
    end

    # Store value
    #
    # @param [Node] value Value to store.
    #
    # @return [Object] Returns +value+.
    #
    # @private
    def save( value )
      @array[ @offset ] = value.get
      value
    end

  end

end
