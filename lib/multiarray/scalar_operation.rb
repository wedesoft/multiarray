module MultiArray

  module ScalarOperation

    def op( *args, &action )
      instance_exec *args, &action
      self
    end

  end

end
