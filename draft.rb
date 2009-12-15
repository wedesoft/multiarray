#!/usr/bin/env ruby
require 'rubygems'
require 'multiarray'

# * ruby
# * jit
# * lazy
# * parallel
# * caching

module Hornetseye

  # @private
  module TypeOperation

    # @private
    def set( value = typecode.default )
      @storage.store self.class, value
      value
    end

    # @private
    def get
      @storage.load self.class
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

  # @private
  module SequenceOperation

    # @private
    def set( value = typecode.default )
      if value.is_a? Array
        for i in 0 ... num_elements
          assign i, i < value.size ? value[ i ] : typecode.default
        end
      else
        op( value ) { |x| set x }
      end
      value
    end

    # @private
    def get
      self
    end

    # @private
    def sel( *indices )
      if indices.empty?
        super *indices
      else
        unless ( 0 ... num_elements ).member? indices.last
          raise "Index must be in 0 ... #{num_elements} " +
                "(was #{indices.last.inspect})"
        end
        element_storage = @storage + indices.last * stride * typecode.bytesize
        element_type.wrap( element_storage ).sel *indices[ 0 ... -1 ]
      end
    end

    # @private
    def op( *args, &action )
      for i in 0 ... num_elements
        sub_args = args.collect do |arg|
          arg.is_a?( Sequence_ ) ? arg[ i ] : arg
        end
        sel( i ).op *sub_args, &action
      end
      self
    end

  end

  Sequence_.class_eval { include SequenceOperation }

end

include Hornetseye

m = INT.new; m.set 1
n = INT.new; n.set 2
r = INT.new.op( m.get, n.get ) { |x,y| set x + y }
puts "#{m} + #{n} = #{r}"
