module Hornetseye

  module TypeOperation

    def set( value = typecode.default )
      puts 'Type#set'
      @memory.store self.class, value
      value
    end

    def get
      puts 'Type#get'
      @memory.load self.class
    end

    def sel
      puts 'Type#sel'
      self
    end

    def op( *args, &action )
      puts 'Type#op'
      instance_exec *args, &action
      self
    end

  end

  Type.class_eval { include TypeOperation }

end
