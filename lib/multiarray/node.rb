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

  # Base class for representing native datatypes and operations (terms).
  class Node

    class << self

      # Get string with information about this class
      #
      # @return [String] Returns +'Node'+.
      def inspect
        'Node'
      end

      # Get unique descriptor of this class
      #
      # The method calls +descriptor( {} )+.
      #
      # @return [String] Descriptor of this class.
      #
      # @see descriptor
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
        retval = retval.align context if context
        retval
      end

      # Align this native datatype with another
      #
      # @param [Class] Native datatype to align with.
      #
      # @return [Class] Aligned native datatype.
      #
      # @private
      def align( context )
        self
      end

      # Element-type of this term
      #
      # @return [Class] Element-type of this datatype.
      def typecode
        self
      end

      # Array type of this term
      #
      # @return [Class] Resulting array type.
      def array_type
        self
      end

      # Convert to pointer type.
      #
      # @return [Class] Corresponding pointer type.
      def pointer_type
        Hornetseye::Pointer( self )
      end

      # Get shape of this term
      #
      # @return [Array<Integer>] Returns +[]+.
      def shape
        []
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

      # Get boolean-based datatype for binary operation
      #
      # @return [Class] Returns +BOOL+.
      def bool_binary( other )
        BOOL
      end

      # Get variables in the definition of this datatype.
      #
      # @return [Set] Returns +Set[]+.
      #
      # @private
      def variables
        Set[]
      end

      # Category operator.
      #
      # @return [FalseClass,TrueClass] Check for equality or kind.
      def ===( other )
        ( other == self ) or ( other.is_a? self ) or ( other.class == self )
      end

      # Strip of all values.
      #
      # Split up into variables, values, and a term where all values have been
      # replaced with variables.
      #
      # @private
      def strip
        return [], [], self
      end

      # Substitute variables.
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

      # Check whether this term is compilable.
      #
      # @return [FalseClass,TrueClass] Returns +true+.
      #
      # @private
      def compilable?
        true
      end

    end

    def array_type
      self.class.array_type
    end

    def pointer_type
      array_type.pointer_type
    end

    def typecode
      array_type.typecode
    end

    def shape
      array_type.shape
    end

    def dimension
      array_type.dimension
    end

    def get
      self
    end

    def to_a
      if dimension == 0
        demand.get
      else
        n = shape.last
        ( 0 ... n ).collect { |i| element( i ).to_a }
      end
    end

    def inspect( indent = nil, lines = nil )
      if dimension == 0 and not indent
        "#{array_type.inspect}(#{force.get.inspect})" # !!!
      else
        prepend = indent ? '' : "#{array_type.inspect}:\n"
        indent = 0
        lines = 0
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
            str = x.force.get.inspect # !!!
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
        prepend + retval
      end
    end

    def to_s
      descriptor( {} )
    end

    def descriptor( hash )
      'Node()'
    end

    def subst( hash )
      hash[ self ] || self
    end

    def compilable?
      typecode.compilable?
    end

    def transpose( *order )
      term = self
      variables = shape.reverse.collect do |i|
        var = Variable.new INDEX( i )
        term = term.element var
        var
      end.reverse
      order.collect { |o| variables[o] }.
        inject( term ) { |retval,var| Lambda.new var, retval }
    end

    def []( *args )
      if args.empty?
        demand.get # force.get
      else
        element( args.last )[ *args[ 0 ... -1 ] ]
      end
    end

    def []=( *args )
      value = args.pop
      value = Node.match( value ).new value unless value.is_a? Node
      if args.empty?
        store value
      else
        element( args.last )[ *args[ 0 ... -1 ] ] = value
      end
    end

    def variables
      Set[]
    end

    def strip
      return [], [], self
    end

    def demand
      self
    end

    def lazy?
      Thread.current[ :lazy ] or not variables.empty?
    end

    def force
      if lazy?
        self
      else
        unless compilable?
          Hornetseye::lazy do
            retval = array_type.new
            retval[] = self
            retval
          end
        else
          GCCFunction.run( self ).demand
        end
      end
    end

    def coerce( other )
      if other.is_a? Node
        return other, self
      else
        return Node.match( other, typecode ).new( other ), self
      end
    end

    def inject( initial = nil, options = {} )
      unless initial.nil?
        initial = Node.match( initial ).new initial unless initial.is_a? Node
        initial_typecode = initial.typecode
      else
        initial_typecode = typecode
      end
      var1 = options[ :var1 ] || Variable.new( initial_typecode )
      var2 = options[ :var2 ] || Variable.new( typecode )
      block = options[ :block ] || yield( var1, var2 )
      if dimension == 0
        if initial
          block.subst( var1 => initial, var2 => self ).demand
        else
          demand
        end
      else
        index = Variable.new Hornetseye::INDEX( nil )
        value = element( index ).
          inject nil, :block => block, :var1 => var1, :var2 => var2
        Inject.new( value, index, initial, block, var1, var2 ).force.get
      end
    end

    def ==( other )
      if other.is_a? Node and other.array_type == array_type
        Hornetseye::lazy { eq( other ).inject( true ) { |a,b| a.and b } }[]
      else
        false
      end
    end

    def diagonal( initial = nil, options = {} )
      if dimension == 0
        demand
      else
        if initial
          initial = Node.match( initial ).new initial unless initial.is_a? Node
          initial_typecode = initial.typecode
        else
          initial_typecode = typecode
        end
        index0 = Variable.new Hornetseye::INDEX( nil )
        index1 = Variable.new Hornetseye::INDEX( nil )
        index2 = Variable.new Hornetseye::INDEX( nil )
        var1 = options[ :var1 ] || Variable.new( initial_typecode )
        var2 = options[ :var2 ] || Variable.new( typecode )
        block = options[ :block ] || yield( var1, var2 )
        value = element( index1 ).element( index2 ).
          diagonal initial, :block => block, :var1 => var1, :var2 => var2
        term = Diagonal.new( value, index0, index1, index2, initial,
                             block, var1, var2 )
        index0.size[] ||= index1.size[]
        Lambda.new( index0, term ).force.get
      end
    end

    def product( filter )
      if dimension == 0
        self * filter
      else
        Hornetseye::lazy { |i,j| self[j].product filter[i] }
      end
    end

    def convolve( filter )
      product( filter ).diagonal { |s,x| s + x }
    end

  end

end
