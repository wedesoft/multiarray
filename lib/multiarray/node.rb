module Hornetseye

  class Node

    class << self

      def inspect
        'Node'
      end

      def to_s
        descriptor( {} )
      end

      def descriptor( hash )
        'Node'
      end

      def match( value, context = nil )
        retval = fit value
        retval = retval.align context if context
        retval
      end

      def align( context )
        self
      end

      def typecode
        self
      end

      def array_type
        self
      end

      def pointer_type
        Pointer( self )
      end

      def shape
        []
      end

      def dimension
        0
      end

      def variables
        Set[]
      end

      def ===( other )
        ( other == self ) or ( other.is_a? self ) or ( other.class == self )
      end

      def strip
        return [], [], self
      end

      def subst( hash )
        hash[ self ] || self
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

    def to_s
      descriptor( {} )
    end

    def descriptor( hash )
      'Node()'
    end

    def subst( hash )
      hash[ self ] || self
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
        demand.get
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

    def force
      if Thread.current[ :lazy ] or not variables.empty?
        self
      else
        lazy do
          if shape.empty?
            demand
          else
            retval = array_type.new
            retval[] = self
            retval
          end
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

    def -@
      if dimension == 0 and variables.empty?
        typecode.new -demand.get
      else
        Unary( :-@ ).new( self ).force
      end
    end

    def +( other )
      other = Node.match( other, typecode ).new other unless other.is_a? Node
      if dimension == 0 and variables.empty? and
          other.dimension == 0 and other.variables.empty?
        target = array_type.coercion other.array_type
        target.new demand.get + other.demand.get
      else
        Plus.new( self, other ).force
      end
    end

    def -( other )
      other = Node.match( other, typecode ).new other unless other.is_a? Node
      if dimension == 0 and variables.empty? and
          other.dimension == 0 and other.variables.empty?
        target = array_type.coercion other.array_type
        target.new demand.get - other.demand.get
      else
        Minus.new( self, other ).force
      end
    end

    def *( other )
      other = Node.match( other, typecode ).new other unless other.is_a? Node
      if dimension == 0 and variables.empty? and
          other.dimension == 0 and other.variables.empty?
        target = array_type.coercion other.array_type
        target.new demand.get * other.demand.get
      else
        Multiply.new( self, other ).force
      end
    end

    def inject( initial = nil, options = {} )
      if dimension == 0
        demand
      else
        if initial
          initial = Node.match( initial ).new initial unless initial.is_a? Node
          initial_typecode = initial.typecode
        else
          initial_typecode = typecode
        end
        index = Variable.new INDEX( nil )
        var1 = options[ :var1 ] || Variable.new( initial_typecode )
        var2 = options[ :var2 ] || Variable.new( typecode )
        block = options[ :block ] || yield( var1, var2 )
        value = element( index ).
          inject initial, :block => block, :var1 => var1, :var2 => var2
        Inject.new( value, index, initial, block, var1, var2 ).force.get
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
        index0 = Variable.new INDEX( nil )
        index1 = Variable.new INDEX( nil )
        index2 = Variable.new INDEX( nil )
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
        lazy { |i,j| self[j].product filter[i] }
      end
    end

    def convolve( filter )
      product( filter ).diagonal { |s,x| s + x }
    end

  end

end
