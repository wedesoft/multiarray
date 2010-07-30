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

  # Base class for representing native elements
  class Element < Node

    class << self

      # Retrieve element from memory
      #
      # @param [Malloc,List] ptr Memory to load element from.
      #
      # @see Malloc#load
      # @see List#load
      def fetch( ptr )
        new *ptr.load( self )
      end

      # Type coercion for native elements
      #
      # @param [Node] other Other native datatype to coerce with.
      #
      # @return [Array<Node>] Result of coercion.
      def coercion( other )
        if self == other
          self
        else
          x, y = other.coerce self
          x.coercion y
        end
      end

    end

    # Constructor initialising element with a value
    #
    # @param [Object] value Initial value for element.
    def initialize( value = self.class.default )
      if Thread.current[ :function ].nil? or value.is_a? GCCValue
        @value = value
      else
        @value = GCCValue.new Thread.current[ :function ], value.to_s
      end
    end

    # Get unique descriptor of this object
    #
    # @param [Hash] hash Labels for any variables.
    #
    # @return [String] Descriptor of this object,
    #
    # @private
    def descriptor( hash )
      "#{self.class.to_s}(#{@value.to_s})"
    end

    # Reevaluate computation
    #
    # @return [Node,Object] Result of computation
    #
    # @see #force
    #
    # @private
    def dup
      if Thread.current[ :function ]
        value = Thread.current[ :function ].variable self.class, 'v'
        value.get.store get
        value
      else
        self.class.new get
      end
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

    # Check whether this term is compilable
    #
    # @return [FalseClass,TrueClass] Returns whether this term is compilable.
    #
    # @private
    def compilable?
      if @value.respond_to? :compilable?
        @value.compilable?
      else
        super
      end
    end

    def skip( index, start )
      self
    end

    # Get value of this native element
    #
    # @return [Object] Value of this native element.
    def get
      @value
    end

    # Store a value in this native element
    #
    # @param [Object] value New value for native element.
    #
    # @return [Object] Returns +value+.
    def store( value )
      if @value.respond_to? :store
        @value.store value.simplify.get
      else
        @value = value.simplify.get
      end
      value
    end

    # Write element to memory
    #
    # @param [Malloc,List] ptr Memory to write element to.
    #
    # @see Malloc#save
    # @see List#save
    #
    # @private
    def write( ptr )
      ptr.save self
    end

    def values
      [ @value ]
    end

  end

end
