module Hornetseye

  module TypeOperation

    def set( value = typecode.default )
      @memory.store self.class, value
      value
    end

    def get
      @memory.load self.class
    end

    def sel
      self
    end

    def op( *args, &action )
      instance_exec *args, &action
      self
    end

  end

  Type.class_eval { include TypeOperation }

end
