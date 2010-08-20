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

  # Class for applying a method to scalars and arrays
  class Method_ < ElementWise_

    class << self

      # Get string with information about this class
      #
      # @return [String] Return string with information about this class.
      def inspect
        key.to_s
      end

    end

  end

  # Create a class deriving from +Method_+
  #
  # @param [Symbol,String] operation Name of operation.
  # @param [Symbol,String] conversion Name of method for type conversion.
  #
  # @return [Class] A class deriving from +Method_+.
  #
  # @see Method_
  # @see Method_.operation
  # @see Method_.conversion
  #
  # @private
  def Method( operation, key, conversion = :contiguous )
    retval = Class.new Method_
    retval.operation = operation
    retval.key = key
    retval.conversion = conversion
    retval
  end

  module_function :Method

end

