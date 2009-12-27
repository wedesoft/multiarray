module Hornetseye

  # This class is used to map Ruby objects to native data types
  #
  # @abstract
  class Type

    class << self

      # Returns the element type for arrays. Otherwise it returns +self+
      #
      # @return [Class] Returns +self+.
      def typecode
        self
      end

      # Check whether an array is empty or not
      #
      # Returns +false+ if this is not an array.
      #
      # @return [FalseClass,TrueClass] Returns +false+.
      def empty?
        size == 0
      end

      # Get shape of multi-dimensional array
      #
      # Returns +[]+ if this is not an array.
      #
      # @return [Array<Integer>] Returns +[]+.
      def shape
        []
      end

      # Get number of elements of multi-dimensional array
      #
      # Returns +1+ if this is not an array.
      #
      # @return [Integer] Number of elements of array. +1+ if this is not an
      # array.
      def size
        shape.inject( 1 ) { |a,b| a * b }
      end

      # Get default value for native datatype.
      #
      # @return [Object] Default (Ruby) value for the native data type.
      #
      # @private
      def default
        delegate.default
      end

    end


    # Returns the element type for arrays
    #
    # Otherwise it returns +self.class+.
    #
    # @return [Class] Element type for arrays. Returns +self.class+ if this is
    # not an array.
    def typecode
      self.class.typecode
    end

    # Check whether an array is empty or not
    #
    # Returns +false+ if this is not an array.
    #
    # @return [FalseClass,TrueClass] Returns boolean indicating whether the
    # array is empty or not. Returns +false+ if this is not an array.
    def empty?
      self.class.empty?
    end

    # Get shape of multi-dimensional array
    #
    # Returns +[]+ if this is not an array.
    #
    # @return [Array<Integer>] Returns shape of array or +[]+ if this is not
    # an array.
    def shape
      self.class.shape
    end

    # Get number of elements of multi-dimensional array
    #
    # Returns +1+ if this is not an array.
    #
    # @return [Integer] Number of elements of array. +1+ if this is not an
    # array.
    def size
      self.class.size
    end

    # Create new instance of this type
    #
    # @param value [Object] Optional initial value for this instance.
    # @option options [Object] :storage Use specified storage object instead
    # of creating a new one.
    def initialize( value = nil, options = {} )
      @delegate = self.class.delegate.new( self, options )
      set value unless value.nil?
    end

    # Retrieve Ruby value of object
    #
    # @return [Object] Ruby value of native data type.
    #
    # @private
    def get
      @delegate.get
    end

    # Set Ruby value of object.
    #
    # @overload set
    #   Set to default value
    # @overload set( value )
    #   Set to specified value
    #   @param value [Object] New Ruby value for native data type.
    def set( *args )
      @delegate.set *args
    end

    # Get view for array element with specified index
    #
    # @param indices [Array<Integer>] Index/indices of array element.
    #
    # @private
    def element( *indices )
      @delegate.element *indices
    end

    # Display type and value of this instance
    #
    # @return [String] Returns string with information about type and value.
    def inspect
      "#{self.class.inspect}(#{get.inspect})"
    end

    # Display value of this instance
    #
    # @return [String] Returns string with the value of this instance.
    def to_s
      get.to_s
    end

    # Convert value of this instance to array
    #
    # @return [Array] Result of calling +to_a+ on value of this instance.
    def to_a
      get.to_a
    end

    # Retrieve element of array
    #
    # @param *indices [Array<Integer>] Index/indices to access element.
    #
    # @return [Object,Type] Ruby object with value of element.
    def at( *indices )
      element( *indices ).get
    end

    alias_method :[], :at

    # Assign value to element of array
    #
    # @param *args [Array<Integer,Object>] Index/indices to access element.
    # The last element of +args+ is the new value to store in the array.
    #
    # @return [Object] Returns +args.last+.
    def assign( *args )
      element( *args[ 0 ... -1 ] ).set args.last
    end

    alias_method :[]=, :assign

  end

end
