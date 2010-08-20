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

  # Class for representing operations on scalars and arrays
  class Operation_ < ElementWise_

  end

  # Create a class deriving from +Operation_+
  #
  # @param [Proc] operation A closure with the operation to perform.
  # @param [Symbol,String] conversion Name of method for type conversion.
  #
  # @return [Class] A class deriving from +Operation_+.
  #
  # @see Operation_
  # @see Operation_.operation
  # @see Operation_.conversion
  #
  # @private
  def Operation( operation, key, conversion = :contiguous )
    retval = Class.new Operation_
    retval.operation = operation
    retval.key = key
    retval.conversion = conversion
    retval
  end

  module_function :Operation

end

