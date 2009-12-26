module Hornetseye

  module Ruby

    def Sequence( front )
      retval = Class.new Sequence_
      retval.front = front
      retval
    end

    module_function :Sequence

  end

end
