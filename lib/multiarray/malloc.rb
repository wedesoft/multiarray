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

  # Malloc is extended with a few methods
  #
  # @see List
  class Malloc

    # Read typed value
    #
    # @param [Class] typecode Load typed value from memory.
    #
    # @return [Node] Value from memory.
    def load( typecode )
      read( typecode.storage_size ).unpack( typecode.directive )
    end

    # Write typed value to memory
    #
    # @param [Node] value Value to write to memory.
    #
    # @return [Node] Returns +value+.
    def save( value )
      write value.values.pack( value.typecode.directive )
      value
    end

  end

end
