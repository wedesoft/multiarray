module Hornetseye

  def Pointer( primitive )
    retval = Class.new Pointer_
    retval.primitive = primitive
    retval
  end

  module_function :Pointer

end
