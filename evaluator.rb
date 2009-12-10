#!/usr/bin/ruby -Ilib
require 'rubygems'
require 'multiarray'
include Hornetseye

module TypeOperation

  def set( value = typecode.default )
    puts 'set'
    @memory.store self.class, value
    value
  end

  def get
    puts 'get'
    @memory.load self.class
  end

  def op( *args, &action )
    puts 'op'
    instance_exec *args, &action
    self
  end

  def -@
    retval = self.class.new
    retval.op( get ) { |x| set -x }
  end

end

a = INT.new 2
b = -a
puts "-#{a.inspect} = #{b.inspect}"
