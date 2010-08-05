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

  # Class for representing binary operations on scalars and arrays
  class Binary_ < Node

    class << self

      # Name of operation
      #
      # @return [Symbol,String] The name of this operation.
      attr_accessor :operation

      # Name of method for type conversion
      #
      # @return [Symbol,String] The name of the method for type conversion.
      attr_accessor :coercion

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

    # Initialise binary operation
    #
    # @param [Node] value1 First operand to apply operation to.
    # @param [Node] value2 Second operand to apply operation to.
    def initialize( value1, value2 )
      @value1, @value2 = value1, value2
    end

    # Get unique descriptor of this object
    #
    # @param [Hash] hash Labels for any variables.
    #
    # @return [String] Descriptor of this object,
    #
    # @private
    def descriptor( hash )
      "(#{@value1.descriptor( hash )}).#{self.class.descriptor( hash )}" +
        "(#{@value2.descriptor( hash )})"
    end

    # Array type of this term
    #
    # @return [Class] Resulting array type.
    #
    # @private
    def array_type
      @value1.array_type.send self.class.coercion, @value2.array_type
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
      self.class.new @value1.subst( hash ), @value2.subst( hash )
    end

    # Get variables contained in this term
    #
    # @return [Set] Returns set of variables.
    #
    # @private
    def variables
      @value1.variables + @value2.variables
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
      vars1, values1, term1 = @value1.strip
      vars2, values2, term2 = @value2.strip
      return vars1 + vars2, values1 + values2, self.class.new( term1, term2 )
    end

    # Reevaluate computation
    #
    # @return [Node,Object] Result of computation
    #
    # @see #force
    #
    # @private
    def demand
      @value1.send self.class.operation, @value2
    end

    def skip( index, start )
      element1 = @value1.skip( index, start )
      element2 = @value2.skip( index, start )
      element1.send self.class.operation, element2
    end

    # Get element of unary operation
    #
    # @param [Integer,Node] i Index of desired element.
    #
    # @return [Node,Object] Element of unary operation.
    def element( i )
      element1 = @value1.dimension == 0 ? @value1 : @value1.element( i )
      element2 = @value2.dimension == 0 ? @value2 : @value2.element( i )
      element1.send self.class.operation, element2
    end

    def slice( start, length )
      element1 = @value1.dimension == 0 ? @value1 :
                                          @value1.slice( start, length )
      element2 = @value2.dimension == 0 ? @value2 :
                                          @value2.slice( start, length )
      element1.send self.class.operation, element2
    end

    # Check whether this term is compilable
    #
    # @return [FalseClass,TrueClass] Returns whether this term is compilable.
    #
    # @private
    def compilable?
      @value1.compilable? and @value2.compilable?
    end

  end

  # Create a class deriving from +Binary_+
  #
  # @param [Symbol,String] operation Name of operation.
  # @param [Symbol,String] conversion Name of method for type conversion.
  #
  # @return [Class] A class deriving from +Binary_+.
  #
  # @see Binary_
  # @see Binary_.operation
  # @see Binary_.coercion
  #
  # @private
  def Binary( operation, coercion = :coercion )
    retval = Class.new Binary_
    retval.operation = operation
    retval.coercion = coercion
    retval
  end

  module_function :Binary

end
