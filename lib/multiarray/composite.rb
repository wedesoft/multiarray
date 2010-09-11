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

  class Composite < Element

    class << self

      attr_accessor :element_type

      attr_accessor :num_elements

      def memory
        element_type.memory
      end

      def storage_size
        element_type.storage_size * num_elements
      end

      def directive
        element_type.directive * num_elements
      end

      def descriptor( hash )
        unless element_type.nil?
          inspect
        else
          super
        end
      end

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

