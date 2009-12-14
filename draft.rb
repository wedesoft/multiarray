#!/usr/bin/env ruby
require 'rubygems'
require 'multiarray'
include Hornetseye

class JITTerm
  def initialize( instr )
    @instr = instr
  end
  def inspect
    @instr
  end
  def +( other )
    JITTerm.new "#{inspect} + #{other.inspect}"
  end
end

module JIT
  def set( value = typecode.default )
    # super value
    puts "store #{value.inspect}"
  end
  def get
    super
  end
  def sel
    super
  end
  def op( *args, &action )
    super *args, &action
  end
end

Type.class_eval { include JIT }

m = INT.new; m.set 1
n = INT.new; n.set 2
r = INT.new.op( JITTerm.new( "i1" ), JITTerm.new( "i2" ) ) { |x,y| set x + y }
puts "#{m} + #{n} = #{r}"
