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

  # Base class for representing native datatypes and operations (terms)
  class Node

    class << self

      # Get unique descriptor of this class
      #
      # The method calls +descriptor( {} )+.
      #
      # @return [String] Descriptor of this class.
      #
      # @see #descriptor
      #
      # @private
      def to_s
        descriptor( {} )
      end

      # Get unique descriptor of this class
      #
      # @param [Hash] hash Labels for any variables.
      #
      # @return [String] Descriptor of this class.
      #
      # @private
      def descriptor( hash )
        'Node'
      end

      # Find matching native datatype to a Ruby value
      #
      # @param [Object] value Value to find native datatype for.
      #
      # @return [Class] Matching native datatype.
      #
      # @private
      def match( value, context = nil )
        retval = fit value
        retval = retval.align context.basetype if context
        retval
      end

      # Element-type of this term
      #
      # @return [Class] Element-type of this datatype.
      def typecode
        self
      end

      def basetype
        self
      end

      def typecodes
        [ self ]
      end

      # Array type of this term
      #
      # @return [Class] Resulting array type.
      #
      # @private
      def array_type
        self
      end

      # Convert to pointer type
      #
      # @return [Class] Corresponding pointer type.
      def pointer_type
        Hornetseye::Pointer( self )
      end

      def indgen( offset = 0, increment = 1 )
        offset
      end

      # Get shape of this term
      #
      # @return [Array<Integer>] Returns +[]+.
      def shape
        []
      end

      # Get size (number of elements) of this value
      #
      # @return [Integer] Returns +1+.
      def size
        1
      end

      def empty?
        size == 0
      end

      # Get dimension of this term
      #
      # @return [Array<Integer>] Returns +0+.
      def dimension
        0
      end

      # Get corresponding contiguous datatype
      #
      # @return [Class] Returns +self+.
      #
      # @private
      def contiguous
        self
      end

      # Get corresponding boolean-based datatype
      #
      # @return [Class] Returns +BOOL+.
      def bool
        BOOL
      end

      def scalar
        self
      end

      def float_scalar
        float.scalar
      end

      # Get boolean-based datatype for binary operation
      #
      # @return [Class] Returns +BOOL+.
      def coercion_bool( other )
        other.coercion( self ).bool
      end

      def maxint
        self
      end

      def coercion_maxint( other )
        coercion( other ).maxint
      end

      # Get corresponding floating-point datatype
      #
      # @return [Class] Returns +DFLOAT+.
      def float
        DFLOAT
      end

      def floating( other )
        other.coercion( self ).float
      end

      def byte
        BYTE
      end

      def coercion_byte( other )
        coercion( other ).byte
      end

      def cond( a, b )
        t = a.coercion b
        Hornetseye::MultiArray( t.typecode, *shape ).coercion t
      end

      def to_type( dest )
        dest
      end

      # Get variables contained in this datatype
      #
      # @return [Set] Returns +Set[]+.
      #
      # @private
      def variables
        Set[]
      end

      # Category operator
      #
      # @return [FalseClass,TrueClass] Check for equality or kind.
      def ===( other )
        ( other == self ) or ( other.is_a? self ) or ( other.class == self )
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
        return [], [], self
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
        hash[ self ] || self
      end

      # Check whether this term is compilable
      #
      # @return [FalseClass,TrueClass] Returns +true+.
      #
      # @private
      def compilable?
        true
      end

      def finalised?
        true
      end

    end

    # Array type of this term
    #
    # @return [Class] Resulting array type.
    def array_type
      self.class.array_type
    end

    # Convert to pointer type
    #
    # @return [Class] Corresponding pointer type.
    def pointer_type
      array_type.pointer_type
    end

    # Element-type of this term
    #
    # @return [Class] Element-type of this datatype.
    def typecode
      array_type.typecode
    end

    def basetype
      array_type.basetype
    end

    # Get shape of this term
    #
    # @return [Array<Integer>] Returns +array_type.shape+.
    def shape
      array_type.shape
    end

    # Get size (number of elements) of this value
    #
    # @return [Integer] Returns +array_type.size+.
    def size
      array_type.size
    end

    def empty?
      array_type.empty?
    end

    # Get dimension of this term
    #
    # @return [Array<Integer>] Returns +array_type.dimension+.
    def dimension
      array_type.dimension
    end

    # Extract native value if this is an element
    #
    # @return [Node,Object] Returns +self+.
    #
    # @private
    def get
      self
    end

    # Convert to Ruby array of objects
    #
    # Perform pending computations and convert native array to Ruby array of
    # objects.
    #
    # @return [Array<Object>] Array of objects.
    def to_a
      if dimension == 0
        force
      else
        n = shape.last
        ( 0 ... n ).collect { |i| element( i ).to_a }
      end
    end

    # Display information about this object
    #
    # @return [String] String with information about this object.
    def inspect( indent = nil, lines = nil )
      if variables.empty?
        if dimension == 0 and not indent
          "#{array_type.inspect}(#{force.inspect})" # !!!
        else
          if indent
            prepend = ''
          else
            prepend = "#{array_type.inspect}:\n"
            indent = 0
            lines = 0
          end
          if empty?
            retval = '[]'
          else
            retval = '[ '
            for i in 0 ... array_type.num_elements
              x = Hornetseye::lazy { element i }
              if x.dimension > 0
                if i > 0
                  retval += ",\n  "
                  lines += 1
                  if lines >= 10
                    retval += '...' if indent == 0
                    break
                  end
                  retval += '  ' * indent
                end
                str = x.inspect indent + 1, lines
                lines += str.count "\n"
                retval += str
                if lines >= 10
                  retval += '...' if indent == 0
                  break
                end
              else
                retval += ', ' if i > 0
                str = x.force.inspect # !!!
                if retval.size + str.size >= 74 - '...'.size -
                    '[  ]'.size * indent.succ
                  retval += '...'
                  break
                else
                  retval += str
                end
              end
            end
            retval += ' ]' unless lines >= 10
          end
          prepend + retval
        end
      else
        to_s
      end
    end

    # Get unique descriptor of this object
    #
    # The method calls +descriptor( {} )+.
    #
    # @return [String] Descriptor of this object.
    #
    # @see #descriptor
    #
    # @private
    def to_s
      descriptor( {} )
    end

    # Get unique descriptor of this object
    #
    # @param [Hash] hash Labels for any variables.
    #
    # @return [String] Descriptor of this object.
    #
    # @private
    def descriptor( hash )
      'Node()'
    end

    def dup
      retval = array_type.new
      retval[] = self
      retval
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
      hash[ self ] || self
    end

    # Check whether this term is compilable
    #
    # @return [FalseClass,TrueClass] Returns +typecode.compilable?+.
    #
    # @private
    def compilable?
      typecode.compilable?
    end

    def finalised?
      self.class.finalised?
    end

    # Retrieve value of array element(s)
    #
    # @param [Array<Integer>] *indices Index/indices to select element.
    #
    # @return [Object,Node] Value of array element or a sub-element.
    def []( *indices )
      if indices.empty?
        force
      else
        if indices.last.is_a? Range
          view = slice indices.last.min, indices.last.size
        else
          view = element indices.last
        end
        view[ *indices[ 0 ... -1 ] ]
      end
    end

    def check_shape( *args )
      args.each do |arg|
        if dimension < arg.dimension
          raise "#{arg.array_type.inspect} has #{arg.dimension} dimension(s) " +
                "but should not have more than #{dimension}"
        end
        if ( shape + arg.shape ).all? { |s| s.is_a? Integer }
          if shape.last( arg.dimension ) != arg.shape
            raise "#{arg.array_type.inspect} has shape #{arg.shape.inspect} " +
                  "(does not match last value(s) of #{shape.inspect})"
          end
        end
      end
    end

    # Assign value to array element(s)
    # 
    # @overload []=( *indices, value )
    #   Assign a value to an element of an array
    #   @param [Array<Integer>] *indices Index/indices to select the element.
    #   @param [Object,Node] value Ruby object with new value.
    #
    # @return [Object,Node] Returns the value.
    def []=( *indices )
      value = indices.pop
      value = Node.match( value ).new value unless value.is_a? Node
      if indices.empty?
        check_shape value
        unless compilable? and value.compilable? and dimension > 0
          store value
        else
          GCCFunction.run self, value
        end
      else
        if indices.last.is_a? Range
          view = slice indices.last.min, indices.last.size
        else
          view = element indices.last
        end
        view[ *indices[ 0 ... -1 ] ] = value
      end
    end

    # Get variables contained in this object
    #
    # @return [Set] Returns +Set[]+.
    #
    # @private
    def variables
      Set[]
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
      return [], [], self
    end

    # Reevaluate computation
    #
    # @return [Node,Object] Result of computation
    #
    # @see #force
    #
    # @private
    def demand
      self
    end

    # Force delayed computation unless in lazy mode
    #
    # @return [Node,Object] Result of computation
    #
    # @see #demand
    #
    # @private
    def force
      if ( dimension > 0 and Thread.current[ :lazy ] ) or not variables.empty?
        self
      elsif finalised?
        get
      else
        unless compilable?
          Hornetseye::lazy do
            retval = array_type.new
            retval[] = self
            retval.get
          end
        else
          GCCFunction.run( pointer_type.new, self ).get
        end
      end
    end

    # Reevaluate term
    #
    # @return [Node,Object] Result of simplification
    #
    # @see demand
    #
    # @private
    def simplify
      #if Thread.current[ :function ] and dimension == 0
      #  demand.dup
      #else
      #  demand
      #end
      dimension == 0 ? demand.dup : demand
    end

    # Coerce with other object
    #
    # @param [Node,Object] other Other object.
    #
    # @return [Array<Node>] Result of coercion.
    #
    # @private
    def coerce( other )
      if other.is_a? Node
        return other, self
      else
        return Node.match( other, self ).new( other ), self
      end
    end

    def decompose
      self
    end

    #def r
    #  if typecode < RGB_
    #    decompose.roll.element 0
    #  else
    #    self
    #  end
    #end

    #def g
    #  if typecode < RGB_
    #    decompose.roll.element 1
    #  else
    #    self
    #  end
    #end

    # def b
    #  if typecode < RGB_
    #    decompose.roll.element 2
    #  else
    #    self
    #  end
    #end

  end

end
