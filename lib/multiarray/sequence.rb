module Hornetseye

  class Sequence_ < CompositeType

    class << self

      attr_accessor :stride

      def inspect
        to_s
      end

      def to_s
        "Sequence(#{element_type.to_s},#{num_elements.to_s})"
      end

    end

  end

  def Sequence( element_type, num_elements,
                stride = element_type.bytesize )
    retval = Class.new Sequence_
    retval.element_type = element_type
    retval.num_elements = num_elements
    retval.stride = stride
    retval
  end

  module_function :Sequence

end
