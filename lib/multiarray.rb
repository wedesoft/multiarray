require 'malloc'
require 'multiarray/storage'
require 'multiarray/list'
require 'multiarray/memory'
require 'multiarray/type_operation'
require 'multiarray/type'
require 'multiarray/descriptortype'
require 'multiarray/int'
require 'multiarray/composite_type'
require 'multiarray/sequence_operation'
require 'multiarray/sequence'
require 'multiarray/multiarray'

class Proc

  unless method_defined? :bind
    def bind( object )
      block, time = self, Time.now
      ( class << object; self end ).class_eval do
        method_name = "__bind_#{time.to_i}_#{time.usec}"
        define_method method_name, &block
        method = instance_method method_name
        remove_method method_name
        method
      end.bind object
    end
  end

end

class Object

  unless method_defined? :instance_exec
    def instance_exec( *arguments, &block )
      block.bind( self )[ *arguments ]
    end
  end

end
