module Hornetseye

  class Sequence

    class << self

      # Create a one-dimensional array
      #
      # Create an array with +num_elements+ elements of type +element_type+.
      #
      # @param [Class] element_type Element type of the array. Should derive
      # from +Type+.
      # @param [Integer] num_elements Number of elements of the array.
      # @return [Sequence_] An array with the specified element type and the
      # specified number of elements.
      #
      # @see #Sequence
      # @see MultiArray.new
      def new( element_type, num_elements )
        Hornetseye::Sequence( element_type, num_elements ).new
      end

    end

  end

  # Create a class deriving from +Sequence_+
  #
  # The parameters +element_type+, +num_elements+, and +stride+ are assigned
  # to the corresponding attributes of the resulting class.
  #
  # @param [Class] element_type Element type of the array type. Should derive
  # from +Type+.
  # @param [Integer] num_elements Number of elements of the array type.
  # @param [Integer] stride Optional stride size for transposed or
  # non-contiguous array types.
  # @return [Class] A class deriving from +Sequence_+.
  #
  # @see Sequence.new
  # @see #MultiArray
  # @see CompositeType.element_type
  # @see CompositeType.num_elements
  # @see Sequence_.stride
  def Sequence( element_type, num_elements,
                stride = element_type.size )
    retval = Class.new Sequence_
    retval.element_type = element_type
    retval.num_elements = num_elements
    retval.stride = stride
    retval
  end

  module_function :Sequence

end
