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

# Range#min and Range#max are replaced for performance reasons
class Range

  public

  alias_method :orig_min, :min

  alias_method :orig_max, :max

  # For performance reasons a specialised method for integers is added
  def min
    if self.begin.is_a? Integer
      self.begin
    else
      orig_min
    end
  end

  # For performance reasons a specialised method for integers is added.
  def max
    if self.end.is_a? Integer
      exclude_end? ? self.end - 1 : self.end
    else
      orig_max
    end
  end

  # Compute the size of a range.
  def size
    max + 1 - min
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
require 'multiarray/lazy'
require 'multiarray/list'
require 'multiarray/malloc'
require 'multiarray/type'
require 'multiarray/object'
require 'multiarray/int_'
require 'multiarray/int'
require 'multiarray/pointer_'
require 'multiarray/pointer'
require 'multiarray/sequence_'
require 'multiarray/sequence'
require 'multiarray/multiarray'
