module Hornetseye

  class Sequence

    class << self

      def new( element_type, num_elements )
        Hornetseye::Sequence( element_type, num_elements ).new
      end

    end

  end

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
