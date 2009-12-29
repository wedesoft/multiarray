# Proc#bind is defined if it does not exist already
class Proc

  unless method_defined? :bind

    # Proc#bind is defined if it does not exist already
    #
    # @private
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

# Object#instance_exec is defined if it does not exist already
class Object

  unless method_defined? :instance_exec

    # Object#instance_exec is defined if it does not exist already
    #
    # @private
    def instance_exec( *arguments, &block )
      block.bind( self )[ *arguments ]
    end

  end

end

# Module#alias_method_chain is defined.
#
# @private
class Module

  unless method_defined? :alias_method_chain

    # Method for creating alias chains.
    #
    # @private
    def alias_method_chain( target, feature, vocalize = target )
      alias_method "#{vocalize}_without_#{feature}", target
      alias_method target, "#{vocalize}_with_#{feature}"
    end

  end

end

require 'malloc'
require 'multiarray/type'
require 'multiarray/object'
require 'multiarray/ruby/list'
require 'multiarray/ruby/object'
require 'multiarray/int_'
require 'multiarray/ruby/int_'
require 'multiarray/ruby/int'
require 'multiarray/int'
require 'multiarray/sequence_'
require 'multiarray/ruby/sequence_'
require 'multiarray/ruby/sequence'
require 'multiarray/sequence'
require 'multiarray/multiarray'
