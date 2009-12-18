# @private
class Proc

  # @private
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

# @private
class Object

  # @private
  unless method_defined? :instance_exec
    def instance_exec( *arguments, &block )
      block.bind( self )[ *arguments ]
    end
  end

end

class Module

  unless method_defined? :alias_method_chain

    def alias_method_chain( target, feature, vocalize = target )
      alias_method "#{vocalize}_without_#{feature}", target
      alias_method target, "#{vocalize}_with_#{feature}"
    end

  end

end

require 'malloc'
#require 'multiarray/delegate'
#require 'multiarray/list'
#require 'multiarray/memory'
require 'multiarray/type'
#require 'multiarray/descriptortype'
require 'multiarray/object'
require 'multiarray/ruby/object'
#require 'multiarray/compact'
#require 'multiarray/int_'
#require 'multiarray/ruby/int_'
#require 'multiarray/int'
#require 'multiarray/composite_type'
#require 'multiarray/sequence_'
#require 'multiarray/ruby/sequence_'
#require 'multiarray/sequence'
#require 'multiarray/multiarray'

# module Hornetseye
# 
#   # @private
#   module TypeOperation
# 
#     # @private
#     def set( value = typecode.default )
#       @storage.store self.class, value
#       value
#     end
# 
#     # @private
#     def get
#       @storage.load self.class
#     end
# 
#     # @private
#     def sel
#       self
#     end
# 
#     # @private
#     def op( *args, &action )
#       instance_exec *args, &action
#       self
#     end
# 
#   end
# 
#   Type.class_eval { include TypeOperation }
# 
#   # @private
#   module SequenceOperation
# 
#     # @private
#     def set( value = typecode.default )
#       if value.is_a? Array
#         for i in 0 ... num_elements
#           assign i, i < value.size ? value[ i ] : typecode.default
#         end
#       else
#         op( value ) { |x| set x }
#       end
#       value
#     end
# 
#     # @private
#     def get
#       self
#     end
# 
#     # @private
#     def sel( *indices )
#       if indices.empty?
#         super *indices
#       else
#         unless ( 0 ... num_elements ).member? indices.last
#           raise "Index must be in 0 ... #{num_elements} " +
#                 "(was #{indices.last.inspect})"
#         end
#         element_storage = @storage + indices.last * stride * typecode.bytesize
#         element_type.wrap( element_storage ).sel *indices[ 0 ... -1 ]
#       end
#     end
# 
#     # @private
#     def op( *args, &action )
#       for i in 0 ... num_elements
#         sub_args = args.collect do |arg|
#           arg.is_a?( Sequence_ ) ? arg[ i ] : arg
#         end
#         sel( i ).op *sub_args, &action
#       end
#       self
#     end
# 
#   end
# 
#   Sequence_.class_eval { include SequenceOperation }
# 
# end



