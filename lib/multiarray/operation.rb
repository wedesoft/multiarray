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
  class Operation_ < Node

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
        inspect
      end

      def finalised?
        false
      end

    end

    # Initialise unary operation
    #
    # @param [Node] value Value to apply operation to.
    def initialize( *values )
      @values = values
    end

    # Get unique descriptor of this object
    #
    # @param [Hash] hash Labels for any variables.
    #
    # @return [String] Descriptor of this object,
    #
    # @private
    def descriptor( hash )
      "(#{@values.first.descriptor( hash )}).#{self.class.descriptor( hash )}" +
        "(#{@values[ 1 .. -1 ].collect { |value| value.descriptor( hash ) }.join ','})"
    end

    # Array type of this term
    #
    # @return [Class] Resulting array type.
    #
    # @private
    def array_type
      array_types = @values.collect { |value| value.array_type }
      array_types.first.send self.class.conversion, *array_types[ 1 .. -1 ]
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
      self.class.new *@values.collect { |value| value.subst( hash ) }
    end

    # Get variables contained in this term
    #
    # @return [Set] Returns set of variables.
    #
    # @private
    def variables
      @values.inject( Set[] ) { |vars,value| vars + value.variables }
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
      stripped = @values.collect { |value| value.strip }
      return stripped.inject( [] ) { |vars,elem| vars + elem[ 0 ] },
           stripped.inject( [] ) { |values,elem| values + elem[ 1 ] },
           self.class.new( *stripped.collect { |elem| elem[ 2 ] } )
    end

    # Reevaluate computation
    #
    # @return [Node,Object] Result of computation
    #
    # @see #force
    #
    # @private
    def demand
      @values.first.send self.class.operation, *@values[ 1 .. -1 ]
    end

    def skip( index, start )
      self.class.new( *@values.collect { |value| value.skip( index, start ) } ).demand
    end

    # Get element of unary operation
    #
    # @param [Integer,Node] i Index of desired element.
    #
    # @return [Node,Object] Element of unary operation.
    def element( i )
      values = @values.collect do |value|
        value.dimension == 0 ? value : value.element( i )
      end
      self.class.new( *values ).demand
    end

    def slice( start, length )
      values = @values.collect do |value|
        value.dimension == 0 ? value : value.slice( start, length )
      end
      self.class.new( *values ).demand
    end

    # Check whether this term is compilable
    #
    # @return [FalseClass,TrueClass] Returns whether this term is compilable.
    #
    # @private
    def compilable?
      @values.all? { |value| value.compilable? }
    end

  end

  # Create a class deriving from +Operation_+
  #
  # @param [Symbol,String] operation Name of operation.
  # @param [Symbol,String] conversion Name of method for type conversion.
  #
  # @return [Class] A class deriving from +Operation_+.
  #
  # @see Operation_
  # @see Operation_.operation
  # @see Operation_.conversion
  #
  # @private
  def Operation( operation, conversion = :contiguous )
    retval = Class.new Operation_
    retval.operation = operation
    retval.conversion = conversion
    retval
  end

  module_function :Operation

end

