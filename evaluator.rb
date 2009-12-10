#!/usr/bin/ruby -Ilib
require 'rubygems'
require 'multiarray'
include Hornetseye

module TypeOperation

  def -@
    puts 'Type#-@'
    retval = self.class.new
    retval.op( get ) { |x| set -x }
  end

end

module SequenceOperation

  def -@
    puts 'Sequence#-@'
    retval = self.class.new
    retval.op( get ) { |x| set -x }
  end

end

puts 'a = INT.new 2'
a = INT.new 2
puts "\# #{a}"
puts

puts 'b = -a'
b = -a
puts "\# #{b}"
puts

puts 's = Sequence.new INT, 3'
s = Sequence.new INT, 3
puts "\# #{s.to_a.inspect}"
puts
puts 's[ 0 ], s[ 1 ], s[ 2 ] = 1, 2, 3'
s[ 0 ], s[ 1 ], s[ 2 ] = 1, 2, 3
puts '# [ 1, 2, 3 ]'
puts

puts 'r = -s'
r = -s
puts "\# #{r.to_a.inspect}"
puts
