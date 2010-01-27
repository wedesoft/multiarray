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

      def []( *args )
        target = Type.fit args
        if target.primitive.dimension > 1
          target = Hornetseye::Sequence OBJECT, args.size
        end
        retval = target.new
        retval[] = args
        retval
      end

    end

  end

  # Create an array class
  #
  # The parameters +element_type+, +num_elements+, and +stride+ are assigned
  # to the corresponding attributes of the resulting class.
  #
  # @param [Class] element_type Element type of the array type. Should derive
  # from +Type+.
  # @param [Integer] num_elements Number of elements of the array type.
  # @param [Integer] stride Optional stride size for transposed or
  # non-contiguous array types.
  # @return [Class] An array class deriving from +Pointer_+.
  #
  # @see Sequence.new
  # @see #MultiArray
  def Sequence( element_type, num_elements,
                stride = element_type.dereference.size )
    sequence = Class.new Sequence_
    sequence.element_type = element_type.dereference
    sequence.num_elements = num_elements
    sequence.stride = stride
    Pointer sequence
  end

  module_function :Sequence

end
