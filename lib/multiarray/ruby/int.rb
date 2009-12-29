module Hornetseye

  module Ruby

    # Create a delegate class deriving from +INT_+
    #
    # @param [Class] front The proxy class this class is a delegate of.
    # @return [Class] A class deriving from +INT_+.
    #
    # @see INT_
    # @see Hornetseye::INT_
    #
    # @private
    def INT( front )
      retval = Class.new INT_
      retval.front = front
      retval
    end

    module_function :INT

  end

end
