# multiarray - Lazy multi-dimensional arrays for Ruby
# Copyright (C) 2010, 2011 Jan Wedekind
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
        name
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

      # Base type of this data type
      #
      # @return [Class] Returns +element_type+.
      #
      # @private
      def basetype
        self
      end

      # Get list of types of composite type
      #
      # @return [Array<Class>] List of types.
      #
      # @private
      def typecodes
        [ self ]
      end

      def shape
        []
      end

      # Generate index array of this type
      #
      # @param [Object] offset First value.
      # @param [Object] offset Increment for consecutive values.
      #
      # @return [Object] Returns +offset+.
      def indgen( offset = 0, increment = 1 )
        offset
      end

      # Get dimension of this term
      #
      # @return [Array<Integer>] Returns +0+.
      def dimension
        0
      end

      # Get this data type
      #
      # @return [Class] Returns +self+.
      #
      # @private
      def identity
        self
      end

      # Check whether this object is an RGB value
      #
      # @return [Boolean] Returns +false+.
      def rgb?
        false
      end

      # Get corresponding boolean-based datatype
      #
      # @return [Class] Returns +BOOL+.
      def bool
        BOOL
      end

      # Get corresponding scalar type
      #
      # @return [Class] Returns +self+.
      def scalar
        self
      end

      # Get corresponding type based on floating-point scalars
      #
      # @return [Class] Corresponding type based on floating-point scalars.
      def float_scalar
        float.scalar
      end

      # Get boolean-based datatype for binary operation
      #
      # @return [Class] Returns +BOOL+.
      def coercion_bool( other )
        other.coercion( self ).bool
      end

      # Get corresponding maximal integer type
      #
      # @return [Class] Returns +self+.
      #
      # @private
      def maxint
        self
      end

      # Get maximum integer based datatype for binary operation
      #
      # @return [Class] Returns type based on maximum integer.
      def coercion_maxint( other )
        coercion( other ).maxint
      end

      # Convert to type based on floating point numbers
      #
      # @return [Class] Corresponding type based on floating point numbers.
      #
      # @private
      def float
        DFLOAT
      end

      # Get floating point based datatype for binary operation
      #
      # @return [Class] Returns type based on floating point numbers.
      def floating( other )
        other.coercion( self ).float
      end

      # Convert to type based on bytes
      #
      # @return [Class] Corresponding type based on bytes.
      #
      # @private
      def byte
        BYTE
      end

      # Get byte-based datatype for binary operation
      #
      # @param [Class] other The other type.
      #
      # @return [Class] Returns type based on bytes.
      def coercion_byte( other )
        coercion( other ).byte
      end

      # Get byte-based datatype for ternary operation
      #
      # @param [Class] a The second type.
      # @param [Class] a The third type.
      #
      # @return [Class] Returns type based on bytes.
      def cond(a, b)
        a.coercion b
      end

      # Convert to different element type
      #
      # @param [Class] dest Element type to convert to.
      #
      # @return [Class] Type based on the different element type.
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
      # @return [Boolean] Check for equality or kind.
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
      # @return [Boolean] Returns +true+.
      #
      # @private
      def compilable?
        true
      end

      # Check whether objects of this class are finalised computations
      #
      # @return [Boolean] Returns +true+.
      #
      # @private
      def finalised?
        true
      end

    end

    def matched?
      true
    end

    def allocate
      Hornetseye::MultiArray(typecode, dimension).new *shape
    end

    # Element-type of this term
    #
    # @return [Class] Element-type of this datatype.
    def typecode
      self.class.typecode
    end

    # Base-type of this term
    #
    # @return [Class] Base-type of this datatype.
    def basetype
      self.class.basetype
    end

    # Get width of two-dimensional array
    #
    # @return [Integer] Width of array.
    def width
      shape[0]
    end

    # Get height of two-dimensional array
    #
    # @return [Integer] Height of array.
    def height
      shape[1]
    end

    # Get size (number of elements) of this value
    #
    # @return [Integer] Returns number of elements of this value.
    def size
      shape.inject 1, :*
    end

    # Duplicate array expression if it is not in row-major format
    #
    # @return [Node] Duplicate of array or +self+.
    def memorise
      if memory
        contiguous_strides = (0 ... dimension).collect do |i|
          shape[0 ... i].inject 1, :*
        end
        if strides == contiguous_strides
          self
        else
          dup
        end
      else
        dup
      end
    end

    # Get memory object
    #
    # @return [Malloc,List,NilClass] This method will return +nil+.
    def memory
      nil
    end

    # Get strides of array
    #
    # @return [Array<Integer>,NilClass] Array strides of this type.
    #
    # @private
    def strides
      nil
    end

    # Get stride for specific index
    #
    # @return [Integer,NilClass] Array stride of this index.
    #
    # @private
    def stride( index )
      nil
    end

    # Check whether this object is an empty array
    #
    # @return [Boolean] Returns whether this object is an empty array.
    def empty?
      size == 0
    end

    # Get shape of this term
    #
    # @return [Array<Integer>] Returns +[]+.
    def shape
      self.class.shape
    end

    # Get dimension of this term
    #
    # @return [Array<Integer>] Returns number of dimensions of this term.
    def dimension
      shape.size
    end

    # Check whether this object is an RGB value
    #
    # @return [Boolean] Returns +false+.
    def rgb?
      typecode.rgb?
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
          "#{typecode.inspect}(#{force.inspect})"
        else
          if indent
            prepend = ''
          else
            prepend = "#{Hornetseye::MultiArray(typecode, dimension).inspect}:\n"
            indent = 0
            lines = 0
          end
          if empty?
            retval = '[]'
          else
            retval = '[ '
            for i in 0 ... shape.last
              x = element i
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
                str = x.force.inspect
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

    # Duplicate object
    #
    # @return [Node] Duplicate of +self+.
    def dup
      retval = Hornetseye::MultiArray(typecode, dimension).new *shape
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
    # @return [Boolean] Returns +typecode.compilable?+.
    #
    # @private
    def compilable?
      typecode.compilable?
    end

    # Check whether this object is a finalised computation
    #
    # @return [Boolean] Returns +self.class.finalised?+.
    #
    # @private
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

    # Check arguments for compatible shape
    #
    # The method will throw an exception if one of the arguments has an incompatible
    # shape.
    #
    # @param [Array<Class>] args Arguments to check for compatibility.
    #
    # @return [Object] The return value should be ignored.
    def check_shape(*args)
      _shape = shape
      args.each do |arg|
        _arg_shape = arg.shape
        if _shape.size < _arg_shape.size
          raise "#{arg.inspect} has #{arg.dimension} dimension(s) " +
                "but should not have more than #{dimension}"
        end
        if ( _shape + _arg_shape ).all? { |s| s.is_a? Integer }
          if _shape.last( _arg_shape.size ) != _arg_shape
            raise "#{arg.inspect} has shape #{arg.shape.inspect} " +
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
      value = typecode.new value unless value.matched?
      if indices.empty?
        check_shape value
        unless compilable? and value.compilable? and dimension > 0
          Store.new(self, value).demand
        else
          GCCFunction.run Store.new(self, value)
        end
        value
      else
        if indices.last.is_a? Range
          view = slice indices.last.min, indices.last.size
        else
          view = element indices.last
        end
        view[*indices[0 ... -1]] = value
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
      if finalised?
        get
      elsif (dimension > 0 and Thread.current[:lazy]) or not variables.empty?
        self
      elsif compilable?
        retval = allocate
        GCCFunction.run Store.new(retval, self)
        retval.demand.get
      else
        retval = allocate
        Store.new(retval, self).demand
        retval.demand.get
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
      dimension == 0 ? demand.dup : demand
    end

    # Coerce with other object
    #
    # @param [Object] other Other object.
    #
    # @return [Array<Node>] Result of coercion.
    #
    # @private
    def coerce(other)
      if other.matched?
        return other, self
      else
        return Node.match(other, self).new(other), self
      end
    end

    # Decompose composite elements
    #
    # This method decomposes composite elements into array.
    #
    # @return [Node] Returns +self+.
    def decompose( i )
      self
    end

  end

end
