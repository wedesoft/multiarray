module Hornetseye

  module Ruby

    def INT( bits, signed )
      retval = Class.new INT_
      retval.bits   = bits
      retval.signed = signed
      retval
    end

    module_function :INT

  end

end
