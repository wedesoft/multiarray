module Hornetseye

  # @private
  module TypeOperation

    # @private
    def set( value = typecode.default )
      @memory.store self.class, value
      value
    end

    # @private
    def get
      @memory.load self.class
    end

    # @private
    def sel
      self
    end

    # @private
    def op( *args, &action )
      instance_exec *args, &action
      self
    end

  end

  Type.class_eval { include TypeOperation }

end
