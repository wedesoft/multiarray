module Hornetseye

  module TypeOperation

    def op( *args, &action )
      instance_exec *args, &action
      self
    end

  end

end
