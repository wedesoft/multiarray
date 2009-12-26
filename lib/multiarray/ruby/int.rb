module Hornetseye

  module Ruby

    def INT( front )
      retval = Class.new INT_
      retval.front = front
      retval
    end

    module_function :INT

  end

end
