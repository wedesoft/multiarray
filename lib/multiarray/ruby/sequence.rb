module Hornetseye

  module Ruby

    # Create a delegate class deriving from +Sequence_+
    #
    # @param [Class] front The proxy class this class is a delegate of.
    #
    # @see Sequence_
    # @see Hornetseye::Sequence_
    #
    # @private
    def Sequence( front )
      retval = Class.new Sequence_
      retval.front = front
      retval
    end

    module_function :Sequence

  end

end
