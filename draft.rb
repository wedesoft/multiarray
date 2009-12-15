#!/usr/bin/ruby -Ilib
#require 'rubygems'
#require 'multiarray'
# include Hornetseye

# * ruby, jit+cache, lazy, parallel, tensor
# * scalars, arrays
# instance_exec for programms?

# factory: jit+cache or Ruby
# factory: lazy

# object.rb, type.rb
# int_.rb, descriptortype.rb, int.rb
# composite_type.rb, sequence_.rb, multiarray.rb, sequence.rb
# list.rb, memory.rb, storage.rb


class Scalar
  class << self
    def new
      ( Thread.current[ :mode ] || Ruby ).const_get( :Scalar ).new
    end
  end
end

module Ruby

  class Scalar
  end

end

module JIT

  class Scalar
  end

end

def jit( &action )
  Thread.current[ :mode ] = JIT
  action.call
  Thread.current[ :mode ] = nil
end

puts Scalar.new

jit do
  puts Scalar.new
end
