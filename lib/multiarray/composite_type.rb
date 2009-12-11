module Hornetseye

  # Abstract class for arrays and composite numbers
  #
  # @abstract
  class CompositeType < Type

    class << self

      # Type of elements this type is composed of
      #
      # @return [Type] The element type of this type.
      #
      # @private
      attr_accessor :element_type

      # Number of elements this type is composed of
      #
      # @return [Integer] The number of elements this type is composed of.
      #
      # @private
      attr_accessor :num_elements

      # Returns the type of storage object for storing values
      #
      # @return [Class] Returns the storage type for the element type.
      #
      # @private
      def memory
        element_type.memory
      end

      # Number of bytes for storing an object of this type
      #
      # @return [Integer] Number of bytes to store +num_elements+ elements of
      # type +element_type+.
      #
      # @private
      def bytesize
        element_type.bytesize * num_elements
      end

      # Returns the element type of this composite type
      #
      # @return [Class] Returns +element_type.basetype+.
      #
      # @private
      def basetype
        element_type.basetype
      end

    end

    # The element type of this object's type
    #
    # @return [Type] The element type of this object's type.
    #
    # @private
    def element_type
      self.class.element_type
    end

    # The number of elements this object's type is composed of
    #
    # @return [Integer] The number of elements this object's type is composed
    # of.
    #
    # @private
    def num_elements
      self.class.num_elements
    end

  end

end
