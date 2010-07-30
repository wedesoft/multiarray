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

module Hornetseye

  class Pointer_ < Node

    class << self

      # Target type of pointer
      #
      # @return [Node] Type of object the pointer is pointing at.
      attr_accessor :target

      def construct( *args )
        new *args
      end

      def inspect
        "*(#{target.inspect})"
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

      # Get default value for elements of this type
      #
      # @return [Memory,List] Memory for storing object of type +target+.
      def default
        target.memory.new target.storage_size
      end

      def ==( other )
        other.is_a? Class and other < Pointer_ and
          target == other.target
      end

      def hash
        [ :Pointer_, target ].hash
      end

      def eql?
        self == other
      end

      def typecode
        target
      end

      def array_type
        target
      end

      def pointer_type
        self
      end

    end

    def initialize( value = self.class.default )
      @value = value
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
      variable = Variable.new self.class
      return [ variable ], [ self ], variable
    end

    def descriptor( hash )
      "#{self.class.to_s}(#{@value.to_s})"
    end

    def store( value )
      result = value.simplify
      self.class.target.new( result.get ).write @value
      result
    end

    # Reevaluate computation
    #
    # @return [Node,Object] Result of computation
    #
    # @see #force
    #
    # @private
    def demand
      self.class.target.fetch( @value ).simplify
    end

    # Lookup element of an array
    #
    # @param [Node] value Index of element.
    # @param [Node] stride Stride for iterating over elements.
    #
    # @private
    def lookup( value, stride )
      if value.is_a? Variable
        Lookup.new self, value, stride
      else
        self.class.new @value + ( stride.get *
                                  self.class.target.storage_size ) * value.get
      end
    end

    def values
      [ @value ]
    end

  end

  def Pointer( target )
    p = Class.new Pointer_
    p.target = target
    p
  end

  module_function :Pointer

end
