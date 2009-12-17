#!/usr/bin/ruby -Ilib
require 'rubygems'
require 'multiarray'
include Hornetseye

# * ruby, jit+cache, lazy, parallel, tensor
# * scalars, arrays
# instance_exec for programms?

# factory: jit+cache or Ruby
# factory: lazy

# object.rb, type.rb
# int_.rb, descriptortype.rb, int.rb
# composite_type.rb, sequence_.rb, multiarray.rb, sequence.rb
# list.rb, memory.rb, storage.rb

module JIT
end

def lazy( &action )
  Thread.current[ :mode ] = JIT
  action.call
  Thread.current[ :mode ] = nil
end

puts OBJECT.inspect
puts OBJECT.new( 3 ).inspect
puts SINT
puts SINT.new( 3 ).inspect
puts Sequence( OBJECT, 3 ).inspect
puts Sequence( OBJECT, 3 ).new.inspect
puts Sequence( INT, 3 ).inspect
puts Sequence( INT, 3 ).new.inspect

#lazy do
#  puts OBJECT.new.inspect
#end
