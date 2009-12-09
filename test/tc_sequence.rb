require 'test/unit'
require 'multiarray'

class TC_Sequence < Test::Unit::TestCase

  def setup
    @@types = [ MultiArray::UBYTE,
                MultiArray::BYTE,
                MultiArray::USINT,
                MultiArray::SINT,
                MultiArray::UINT,
                MultiArray::INT,
                MultiArray::ULONG,
                MultiArray::LONG ]
  end

  def teardown
    @@types = nil
  end

  def test_sequence_to_s
    for t in @@types
      assert_equal "Sequence(#{t.to_s},3)", MultiArray::Sequence( t, 3 ).to_s
    end
  end

  def test_sequence_inspect
    for t in @@types
      assert_equal "Sequence(#{t.inspect},3)",
                   MultiArray::Sequence( t, 3 ).inspect
    end
  end

end
