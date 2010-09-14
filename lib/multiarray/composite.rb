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

  # Base class for composite types
  class Composite < Element

    class << self

      # Access element type of composite type
      #
      # @return [Class] The element type.
      attr_accessor :element_type

      # Get number of elements of composite type
      #
      # @return [Integer] Number of elements.
      attr_accessor :num_elements

      # Memory type required to store elements of this type
      #
      # @return [Class] Returns +element_type.memory+.
      #
      # @private
      def memory
        element_type.memory
      end

      # Get storage size to store an element of this type
      #
      # @return [Integer] Returns +element_type.storage_size * num_elements+.
      #
      # @private
      def storage_size
        element_type.storage_size * num_elements
      end

      # Directive for packing/unpacking elements of this type
      #
      # @return [String] Returns string with directive.
      #
      # @private
      def directive
        element_type.directive * num_elements
      end

      # Get unique descriptor of this class
      #
      # @param [Hash] hash Labels for any variables.
      #
      # @return [String] Descriptor of this class.
      #
      # @private
      def descriptor( hash )
        unless element_type.nil?
          inspect
        else
          super
        end
      end

      # Base type of this data type
      #
      # @return [Class] Returns +element_type+.
      #
      # @private
      def basetype
        element_type
      end

      def typecodes
        [ element_type ] * num_elements
      end

      def scalar
        element_type
      end

    end

  end

end

