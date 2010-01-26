module Hornetseye

  # This class is used to map Ruby objects to native data types
  #
  # @abstract
  class Type

    class << self

      # Returns the dereferenced type for pointers
      #
      # Returns the dereferenced type for pointers.
      # Otherwise it returns +self+.
      #
      # @return [Class] Returns +self+.
      def dereference
        self
      end

      # Returns the element type for arrays
      #
      # Returns +self+ if this is not an array.
      #
      # @return [Class] Returns +self+.
      def typecode
        self
      end

      # Dimensions of arrays
      #
      # Returns +[]+ if this is not an array.
      #
      # @return [Array] Returns +[]+.
      def shape
        []
      end

      # Number of elements
      #
      # @return [Integer] Number of elements
      #
      # @return [Integer] Returns +1+.
      def size
        shape.inject( 1 ) { |a,b| a * b }
      end

    end

    # Create new instance of this type
    #
    # @param [Object] value Optional initial value for this instance.
    def initialize( value = nil )
      set value if value
    end

    # Display type and value of this instance
    #
    # @return [String] Returns string with information about type and value.
    def inspect
      "#{self.class.inspect}(#{@value.inspect})"
    end

    # Display value of this instance
    #
    # @return [String] Returns string with the value of this instance.
    def to_s
      get.to_s
    end

    # Retrieve Ruby value of object
    #
    # @return [Object] Ruby value of native data type.
    def []
      get
    end

    # Set Ruby value of object
    #
    # @param [Object] value New Ruby value for native data type.
    #
    # @return [Object] The parameter +value+ or the default value.
    def []=( value )
      set value
    end

    # Retrieve Ruby value of object
    #
    # @return [Object] Ruby value of native data type.
    #
    # @private
    def get
      delay.instance_exec { @value }
    end

    # Set Ruby value of object
    #
    # Set to specified value.
    #
    # @param [Object] value New Ruby value for native data type.
    #
    # @return [Object] The parameter +value+ or the default value.
    #
    # @private
    def set( value )
      @value = value
    end

    def fetch
      self
    end

    def operation( *args, &action )
      instance_exec *args.collect { |arg| arg.force.fetch.get }, &action
      self
    end

    def delay
      if not Thread.current[ :lazy ] or @value.is_a? Lazy
        self
      else
        self.class.new Lazy.new( self )
      end
    end

    def force
      if Thread.current[ :lazy ] or not @value.is_a? Lazy
        self
      else
        @value.force
      end
    end

    def -@
      if is_a?( Pointer_ ) and self.class.primitive < Sequence_
        retval = self.class.new
      else
        retval = self.class.dereference.new
      end
      retval.operation( self ) { |x| set -x }
      retval
    end

    def +@
      self
    end

    def +( other )
      if is_a?( Pointer_ ) and self.class.primitive < Sequence_
        retval = self.class.new
      else
        retval = self.class.dereference.new
      end
      retval.operation( self, other ) { |x,y| set x + y }
      retval
    end

    def match( value, context = nil )
      retval = fit value
      retval = retval.align context if context
      retval
    end

    def ==( other )
      if other.class == self.class
        other.get == get
      else
        false
      end
    end

  end

end
