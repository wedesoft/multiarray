#!/usr/bin/ruby -Ilib
require 'rubygems'
require 'multiarray'
include Hornetseye

module TypeOperation

  def set( value = typecode.default )
    puts 'Type#set'
    @memory.store self.class, value
    value
  end

  def get
    puts 'Type#get'
    @memory.load self.class
  end

  def sel
    puts 'Type#sel'
    self
  end

  def op( *args, &action )
    puts 'Type#op'
    instance_exec *args, &action
    self
  end

  def -@
    puts 'Type#-@'
    retval = self.class.new
    retval.op( get ) { |x| set -x }
  end

end

module SequenceOperation

  def op( *args, &action )
    puts 'Sequence_#sel'
    for i in 0 ... num_elements
      sub_args = args.collect do |arg|
        arg.is_a?( Sequence_ ) ? arg[ i ] : arg
      end
      sel( i ).op *sub_args, &action
    end
    self
  end

end

puts "a = INT.new 2"
a = INT.new 2
puts "\# #{a}"
puts

puts "b = -a"
b = -a
puts "\# #{b}"
puts

puts "s = Sequence.new INT, 3"
s = Sequence.new INT, 3
puts "\# #{s}"
puts
