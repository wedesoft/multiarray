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

  # Class for representing Ruby objects
  class OBJECT < Element

    class << self

      # Get string with information about this class
      #
      # @return [String] Returns +'OBJECT'+.
      def inspect
        'OBJECT'
      end

      # Get unique descriptor of this class
      #
      # @param [Hash] hash Labels for any variables.
      #
      # @return [String] Descriptor of this class.
      #
      # @private
      def descriptor( hash )
        inspect
      end

      # Get memory type required to store elements of this type
      #
      # @return [Class] Returns +List+.
      #
      # @see List
      #
      # @private
      def memory
        List
      end

      # Get storage size to store an element of this type
      #
      # @return [Integer] Returns +1+.
      #
      # @private
      def storage_size
        1
      end

      # Get default value for elements of this type
      #
      # @return [Object] Returns +nil+.
      #
      # @private
      def default
        nil
      end

      def coercion( other )
        if other < Sequence_
          other.coercion self
        else
          self
        end
      end

      # Coerce with other object
      #
      # @param [Node,Object] other Other object.
      #
      # @return [Array<Node>] Result of coercion.
      def coerce( other )
        return self, self
      end

      def bool
        self
      end

      def float
        OBJECT
      end

      # Check whether this term is compilable
      #
      # @return [FalseClass,TrueClass] Returns +false+.
      #
      # @private
      def compilable?
        false
      end

    end

    # Namespace containing method for matching elements of type OBJECT
    #
    # @see OBJECT
    #
    # @private
    module Match

      # Method for matching elements of type OBJECT
      #
      # @param [Array<Object>] *values Values to find matching native element
      # type for.
      #
      # @return [Class] Native type fitting all values.
      #
      # @see OBJECT
      #
      # @private
      def fit( *values )
        OBJECT
      end

      def align( context )
        self
      end

    end

    Node.extend Match

  end

  def OBJECT( value )
    OBJECT.new value
  end

  module_function :OBJECT

end
