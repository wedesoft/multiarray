require 'test/unit'
require 'multiarray'

class TC_Sequence < Test::Unit::TestCase

  def setup
    @@types = [ Hornetseye::UBYTE,
                Hornetseye::BYTE,
                Hornetseye::USINT,
                Hornetseye::SINT,
                Hornetseye::UINT,
                Hornetseye::INT,
                Hornetseye::ULONG,
                Hornetseye::LONG ]
  end

  def teardown
    @@types = nil
  end

  def test_sequence_to_s
    for t in @@types
      assert_equal "Sequence(#{t.to_s},3)", Hornetseye::Sequence( t, 3 ).to_s
    end
  end

  def test_sequence_inspect
    for t in @@types
      assert_equal "Sequence(#{t.inspect},3)",
                   Hornetseye::Sequence( t, 3 ).inspect
    end
  end

  def test_bytesize
    for t in @@types
      assert_equal t.bytesize * 3, Hornetseye::Sequence( t, 3 ).bytesize
    end
  end

  def test_typecode
    for t in @@types
      assert_equal t, Hornetseye::Sequence( t, 3 ).typecode
    end
  end

  def test_shape
    for t in @@types
      assert_equal [ 3 ], Hornetseye::Sequence( t, 3 ).shape
    end
  end

  def test_size
    for t in @@types
      assert_equal 3, Hornetseye::Sequence( t, 3 ).size
    end
  end

end
