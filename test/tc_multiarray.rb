require 'test/unit'
begin
  require 'rubygems'
rescue LoadError
end
Kernel::require 'multiarray'

class TC_MultiArray < Test::Unit::TestCase

#   def setup
#     @@types = [ Hornetseye::UBYTE,
#                 Hornetseye::BYTE,
#                 Hornetseye::USINT,
#                 Hornetseye::SINT,
#                 Hornetseye::UINT,
#                 Hornetseye::INT,
#                 Hornetseye::ULONG,
#                 Hornetseye::LONG ]
#   end
# 
#   def teardown
#     @@types = nil
#   end

  def test_first
  end

  def xtest_multiarray_new
    for t in @@types
      m = Hornetseye::MultiArray.new t, 3, 2
      m.set
      assert_equal [ [ 0, 0, 0 ], [ 0, 0, 0 ] ], m.to_a
    end
  end

end

