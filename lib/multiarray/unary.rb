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

  # Class for representing unary operations on scalars and arrays
  class Unary_ < Node

    class << self

      # Name of operation
      #
      # @return [Symbol,String] The name of this operation.
      attr_accessor :operation

      # Name of method for type conversion
      #
      # @return [Symbol,String] The name of the method for type conversion.
      attr_accessor :conversion

      # Get string with information about this class
      #
      # @return [String] Return string with information about this class.
      def inspect
        operation.to_s
      end

      # Get unique descriptor of this class
      #
      # @param [Hash] hash Labels for any variables.
      #
      # @return [String] Descriptor of this class.
      #
      # @private
      def descriptor( hash )
        operation.to_s
      end

    end

    # Initialise unary operation
    #
    # @param [Node] value Value to apply operation to.
    def initialize( value )
      @value = value
    end

    # Get unique descriptor of this object
    #
    # @param [Hash] hash Labels for any variables.
    #
    # @return [String] Descriptor of this object,
    #
    # @private
    def descriptor( hash )
      "(#{@value.descriptor( hash )}).#{self.class.descriptor( hash )}"
    end

    # Array type of this term
    #
    # @return [Class] Resulting array type.
    #
    # @private
    def array_type
      @value.array_type.send self.class.conversion
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
      self.class.new @value.subst( hash )
    end

    # Get variables contained in this term
    #
    # @return [Set] Returns set of variables.
    #
    # @private
    def variables
      @value.variables
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
      vars, values, term = @value.strip
      return vars, values, self.class.new( term )
    end

    # Reevaluate computation
    #
    # @return [Node,Object] Result of computation
    #
    # @see #force
    #
    # @private
    def demand
      @value.send self.class.operation
    end

    # Get element of unary operation
    #
    # @param [Integer,Node] i Index of desired element.
    #
    # @return [Node,Object] Element of unary operation.
    def element( i )
      @value.element( i ).send self.class.operation
    end

    def skip( index, start )
      @value.skip( index, start ).send self.class.operation
    end

    # Check whether this term is compilable
    #
    # @return [FalseClass,TrueClass] Returns whether this term is compilable.
    #
    # @private
    def compilable?
      @value.compilable?
    end

  end

  # Create a class deriving from +Unary_+
  #
  # @param [Symbol,String] operation Name of operation.
  # @param [Symbol,String] conversion Name of method for type conversion.
  #
  # @return [Class] A class deriving from +Unary_+.
  #
  # @see Unary_
  # @see Unary_.operation
  # @see Unary_.conversion
  #
  # @private
  def Unary( operation, conversion = :contiguous )
    retval = Class.new Unary_
    retval.operation = operation
    retval.conversion = conversion
    retval
  end

  module_function :Unary

end
