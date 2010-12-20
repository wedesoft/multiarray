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

  # Class for representing native booleans
  class BOOL < Element

    class << self

      # Get string with information about this class
      #
      # @return [String] Returns 'BOOL'
      def inspect
        'BOOL'
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

      # Retrieve element from memory
      #
      # @param [Malloc] ptr Memory to load element from.
      #
      # @see Malloc#load
      #
      # @return [BOOL] Result of fetch operation.
      #
      # @private
      def fetch( ptr )
        new ptr.load( self ).first.ne( 0 )
      end

      # Memory type required to store elements of this type
      #
      # @return [Class] Returns +Malloc+.
      #
      # @private
      def memory_type
        Malloc
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
      # @return [Object] Returns +false+.
      #
      # @private
      def default
        false
      end

      # Directive for packing/unpacking elements of this type
      #
      # @return [String] Returns 'c'.
      #
      # @private
      def directive
        'c'
      end

    end

    # Write element to memory
    #
    # @param [Malloc] ptr Memory to write element to.
    #
    # @return [BOOL] Returns +self+.
    #
    # @see Malloc#save
    #
    # @private
    def write( ptr )
      ptr.save UBYTE.new( get.conditional( 1, 0 ) )
      self
    end

    # Namespace containing method for matching elements of type BOOL
    #
    # @see BOOL
    #
    # @private
    module Match

      # Method for matching elements of type BOOL
      #
      # @param [Array<Object>] *values Values to find matching native element
      #        type for.
      #
      # @return [Class] Native type fitting all values.
      #
      # @see BOOL
      #
      # @private
      def fit( *values )
        if values.all? { |value| [ false, true ].member? value }
          BOOL
        else
          super *values
        end
      end

    end

    Node.extend Match

  end

  # Shortcut for constructor
  #
  # The method calls +BOOL.new+.
  #
  # @param [Boolean] value Boolean value.
  #
  # @return [BOOL] The wrapped boolean value.
  #
  # @private
  def BOOL( value )
    BOOL.new value
  end

  module_function :BOOL

end
