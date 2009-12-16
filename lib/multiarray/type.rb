module Hornetseye

  # This class is used to map Ruby objects to native data types
  #
  # @abstract
  class Type

    class << self

      def new( *args )
        class_name = name.split( '::' ).last
        target = ( Thread.current[ :mode ] || Ruby ).const_get class_name
        if self == target
          super *args
        else
          target.new *args
        end
      end

      # Create +Delegate+ object for storing a value
      #
      # @return [Delegate] Object for storing a value of this type.
      #
      # @private
      #def alloc
      #  delegate.alloc delegate_size
      #end

      # Create new instance viewing the data of the indicated +Storage+ object
      #
      # @return [Type] Object of this class.
      #
      # @private
      #def wrap( storage )
      #  new nil, :storage => storage
      #end

      # Returns the element type for arrays. Otherwise it returns +self+
      #
      # @return [Class] Returns +self+.
      def typecode
        self
      end

      # Returns the element type for arrays and composite numbers
      #
      # Otherwise it returns +self+.
      #
      # @return [Class] Returns +self+.
      #
      # @private
      #def basetype
      #  self
      #end

      # Check whether an array is empty or not
      #
      # Returns +false+ if this is not an array.
      #
      # @return [FalseClass,TrueClass] Returns +false+.
      #def empty?
      #  size == 0
      #end

      # Get shape of multi-dimensional array
      #
      # Returns +[]+ if this is not an array.
      #
      # @return [Array<Integer>] Returns +[]+.
      #def shape
      #  []
      #end

      # Get number of elements of multi-dimensional array
      #
      # Returns +1+ if this is not an array.
      #
      # @return [Integer] Number of elements of array. +1+ if this is not an
      # array.
      #def size
      #  shape.inject( 1 ) { |a,b| a * b }
      #end

    end

    # Get +Storage+ object used to store the data of this instance
    #
    # @return [Storage]
    #
    # @private
    #attr_accessor :storage

    # Get number of bytes memory required to store the data of an instance
    #
    # @return [Integer] Number of bytes.
    #
    # @private
    #def bytesize
    #  self.class.bytesize
    #end

    # Returns the element type for arrays
    #
    # Otherwise it returns +self.class+.
    #
    # @return [Class] Element type for arrays. Returns +self.class+ if this is
    # not an array.
    #def typecode
    #  self.class.typecode
    #end

    # Returns the element type for arrays and composite numbers
    #
    # Otherwise it returns +self.class+.
    #
    # @return [Class] Element type for arrays and composite numbers. Returns
    # +self.class+ if this is not an array.
    #
    # @private
    #def basetype
    #  self.class.basetype
    #end
    
    # Check whether an array is empty or not
    #
    # Returns +false+ if this is not an array.
    #
    # @return [FalseClass,TrueClass] Returns boolean indicating whether the
    # array is empty or not. Returns +false+ if this is not an array.
    #def empty?
    #  self.class.empty?
    #end

    # Get shape of multi-dimensional array
    #
    # Returns +[]+ if this is not an array.
    #
    # @return [Array<Integer>] Returns shape of array or +[]+ if this is not
    # an array.
    #def shape
    #  self.class.shape
    #end

    # Get number of elements of multi-dimensional array
    #
    # Returns +1+ if this is not an array.
    #
    # @return [Integer] Number of elements of array. +1+ if this is not an
    # array.
    #def size
    #  self.class.size
    #end

    # Create new instance of this type
    #
    # @param value [Object] Optional initial value for this instance.
    # @option options [Storage] :storage (self.class.alloc) Use specified
    # +Storage+ object instead of creating a new one.
    #
    # @see alloc
    #
    # @private
    #def initialize( value = nil, options = {} )
    #  @delegate = options[ :delegate ] || self.class.alloc
    #  set value unless value.nil?
    #end

    def initialize( value = nil )
      set value unless value.nil?
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
    # @return [Object,Type] Ruby object with value of element.
    #
    # @see #[]
    #def at( *indices )
    #  sel( *indices ).get
    #end

    #alias_method :[], :at

    # Assign value to element of array
    #
    # @param *args [Array<Integer,Object>] Index/indices to access element.
    # The last element of +args+ is the new value to store in the array.
    #
    # @return [Object] Returns +args.last+.
    #def assign( *args )
    #  sel( *args[ 0 ... -1 ] ).set args.last
    #end

    #alias_method :[]=, :assign

  end

end
