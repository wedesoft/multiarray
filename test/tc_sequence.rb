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

  def test_get_set
  end

  def test_at_assign
    for t in @@types
      s = Hornetseye::Sequence( t, 3 ).new
      s[ 0 ], s[ 1 ], s[ 2 ] = 0, 0, 0
      assert_equal [ 0, 0, 0 ], [ s.at( 0 ), s.at( 1 ), s.at( 2 ) ]
      assert_equal [ 1, 2, 3 ], [ s.assign( 0, 1 ),
                                  s.assign( 1, 2 ),
                                  s.assign( 2, 3 ) ]
      assert_equal [ 1, 2, 3 ], [ s.at( 0 ), s.at( 1 ), s.at( 2 ) ]
      assert_raise( ArgumentError ) { s.at 0, 0 }
      assert_nothing_raised { s.at }
      s = Hornetseye::Sequence( t, 3 ).new
      s[ 0 ], s[ 1 ], s[ 2 ] = 0, 0, 0
      assert_equal [ 0, 0, 0 ], [ s[ 0 ], s[ 1 ], s[ 2 ] ]
      assert_equal [ 1, 2, 3 ], [ s[ 0 ] = 1, s[ 1 ] = 2, s[ 2 ] = 3 ]
      assert_equal [ 1, 2, 3 ], [ s[ 0 ], s[ 1 ], s[ 2 ] ]
      assert_raise( ArgumentError ) { s[ 0, 0 ] }
      assert_nothing_raised { s[] }
    end
  end

end
