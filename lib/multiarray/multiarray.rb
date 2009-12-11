module Hornetseye

  class MultiArray

    class << self

      # Create a multi-dimensional array
      #
      # Creates a multi-dimensional array with elements of type
      # +element_type+ and dimensions +*shape+.
      #
      # @param [Class] element_type Element type of the array. Should derive
      # from +Type+.
      # @param [Array<Integer>] *shape The dimensions of the array.
      # @return [Type,Sequence_] An array with the specified element type and
      # the specified dimensions.
      #
      # @see #MultiArray
      # @see Sequence.new
      def new( element_type, *shape )
        Hornetseye::MultiArray( element_type, *shape ).new
      end

    end

  end

  # Create a multi-dimensional array class
  #
  # Creates a multi-dimensional array class with elements of type
  # +element_type+ and dimensions +*shape+.
  #
  # @param [Class] element_type Element type of the array type. Should derive
  # from +Type+.
  # @param [Array<Integer>] *shape The dimensions of the array type.
  # @return [Class] A class deriving from +Type+ or +Sequence_+.
  #
  # @see MultiArray.new
  # @see #Sequence
  def MultiArray( element_type, *shape )
    if shape.empty?
      element_type
    else
      MultiArray Sequence( element_type, shape.first ), *shape[ 1 .. -1 ]
    end
  end

  module_function :MultiArray

end
