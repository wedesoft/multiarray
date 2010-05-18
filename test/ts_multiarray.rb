#!/usr/bin/env ruby
require 'tc_object'
require 'test/unit'
begin
  require 'rubygems'
rescue LoadError
end
Kernel::require 'multiarray'

class TC_Test < Test::Unit::TestCase

  INT = Hornetseye::INT

  def test_all
    INT.new 3
  end

end
