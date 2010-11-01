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

  class ElementWise_ < Node

    class << self

      # Name of operation
      #
      # @return [Proc] A closure with the operation.
      attr_accessor :operation

      # Unique key to identify operation.
      #
      # @return [Symbol,String] A unique key to identify this operation.
      attr_accessor :key

      # Name of method for type conversion
      #
      # @return [Proc] A closure for doing the type conversion.
      attr_accessor :conversion

      # Get string with information about this class
      #
      # @return [String] Return string with information about this class.
      def inspect
        key.to_s
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

      # Check whether objects of this class are finalised computations
      #
      # @return [Boolean] Returns +false+.
      #
      # @private
      def finalised?
        false
      end

    end

    # Initialise unary operation
    #
    # @param [Node] value Value to apply operation to.
    def initialize( *values )
      @values = values
      check_shape *values
    end

    # Get unique descriptor of this object
    #
    # @param [Hash] hash Labels for any variables.
    #
    # @return [String] Descriptor of this object,
    #
    # @private
    def descriptor( hash )
      "#{self.class.descriptor( hash )}" +
        "(#{@values.collect { |value| value.descriptor( hash ) }.join ','})"
    end

    # Get type of result of delayed operation
    #
    # @return [Class] Type of result.
    #
    # @private
    def array_type
      array_types = @values.collect { |value| value.array_type }
      retval = self.class.conversion.call *array_types
      ( class << self; self; end ).instance_eval do
        define_method( :array_type ) { retval }
      end
      retval
    end

    # Reevaluate computation
    #
    # @return [Node,Object] Result of computation
    #
    # @see #force
    #
    # @private
    def demand
      self.class.operation.call *@values
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

    # Skip elements of an array
    #
    # @param [Variable] index Variable identifying index of array.
    # @param [Node] start Wrapped integer with number of elements to skip.
    #
    # @return [Node] Returns element-wise operation with elements skipped on each
    #         operand.
    #
    # @private
    def skip( index, start )
      skipped = *@values.collect { |value| value.skip( index, start ) }
      self.class.new( *skipped ).demand
    end

    # Get element of unary operation
    #
    # @param [Integer,Node] i Index of desired element.
    #
    # @return [Node,Object] Element of unary operation.
    #
    # @private
    def element( i )
      values = @values.collect do |value|
        value.dimension == 0 ? value : value.element( i )
      end
      self.class.new( *values ).demand
    end

    # Extract array view with part of array
    #
    # @param [Integer,Node] start Number of elements to skip.
    # @param [Integer,Node] length Size of array view.
    #
    # @return [Node] Array view with the specified elements.
    #
    # @private
    def slice( start, length )
      values = @values.collect do |value|
        value.dimension == 0 ? value : value.slice( start, length )
      end
      self.class.new( *values ).demand
    end

    # Decompose composite elements
    #
    # This method decomposes composite elements into array.
    #
    # @return [Node] Result of decomposition.
    def decompose( i )
      values = @values.collect { |value| value.decompose i }
      self.class.new( *values ).demand
    end

    # Check whether this term is compilable
    #
    # @return [Boolean] Returns whether this term is compilable.
    #
    # @private
    def compilable?
      array_type.compilable? and @values.all? { |value| value.compilable? }
    end

  end

  # Create a class deriving from +ElementWise_+
  #
  # @param [Proc] operation A closure with the operation to perform.
  # @param [Symbol,String] key A unique descriptor to identify this operation.
  # @param [Proc] conversion A closure for performing the type conversion.
  #
  # @return [Class] A class deriving from +ElementWise_+.
  #
  # @see ElementWise_
  # @see ElementWise_.operation
  # @see ElementWise_.key
  # @see ElementWise_.conversion
  #
  # @private
  def ElementWise( operation, key, conversion = lambda { |t| t.send :contiguous } )
    retval = Class.new ElementWise_
    retval.operation = operation
    retval.key = key
    retval.conversion = conversion
    retval
  end

  module_function :ElementWise

end

