#!/usr/bin/ruby -Ilib
require 'rubygems'
require 'multiarray'

# * ruby
# * jit+cache
# * lazy
# * parallel

# factory: jit+cache or Ruby
# factory: lazy

# object.rb, type.rb
# int_.rb, descriptortype.rb, int.rb
# composite_type.rb, sequence_.rb, multiarray.rb, sequence.rb
# list.rb, memory.rb, storage.rb

include Hornetseye

class OBJECT
  module Lazy
    def alloc
      :lazy
    end
    module_function :alloc
  end
  module Ruby
    def alloc
      :Ruby
    end
    module_function :alloc
  end
  def initialize
    @delegate = self.class.const_get( Thread.current[ :multiarray ] ).alloc
  end
end

Thread.current[ :multiarray ] = :Lazy
puts OBJECT.new.inspect
#m = OBJECT.new; m.set 1
#n = OBJECT.new; n.set 2
#r = OBJECT.new.op( m.get, n.get ) { |x,y| set x + y }
#puts "#{m} + #{n} = #{r}"
