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

  class List

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

    def to_s
      "List(#{@array[ @offset .. -1 ]})"
    end

    def +( offset )
      List.new 0, :array => @array, :offset => @offset + offset
    end

    def load( typecode )
      @array[ @offset ]
    end

    def save( value )
      @array[ @offset ] = value.get
      value
    end

  end

end
