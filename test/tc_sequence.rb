require 'test/unit'
Kernel::require 'multiarray'

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

  def test_default
    for t in @@types
      assert_equal [ t.default ] * 3, Hornetseye::Sequence( t, 3 ).default.to_a
    end
  end

  def test_sequence_to_s
    for t in @@types
      assert_equal "Sequence.#{t.to_s.downcase}(3)",
                   Hornetseye::Sequence( t, 3 ).to_s
    end
  end

  def test_sequence_inspect
    for t in @@types
      assert_equal "Sequence.#{t.inspect.downcase}(3)",
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

  def test_empty
    for t in @@types
      assert Hornetseye::Sequence( t, 0 ).new.empty?
      assert !Hornetseye::Sequence( t, 3 ).new.empty?
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

  def test_inspect
    for t in @@types
      s = Hornetseye::Sequence( t, 3 ).new
      s[] = [ 1, 2, 3 ]
      assert_equal "Sequence.#{t.inspect.downcase}(3):\n[ 1, 2, 3 ]", s.inspect
    end
  end

  def test_to_a
    for t in @@types
      s = Hornetseye::Sequence( t, 3 ).new
      s[] = [ 1, 2, 3 ]
      assert_equal [ 1, 2, 3 ], s.to_a
    end
  end

  def test_get_set
    for t in @@types
      s1 = Hornetseye::Sequence( t, 3 ).new
      s1[] = 2
      assert_equal 0, s1.set
      assert_equal [ 0, 0, 0 ], s1.get.to_a
      assert_equal [ 0, 0, 0 ], s1.to_a
      assert_equal 1, s1.set( 1 )
      assert_equal [ 1, 1, 1 ], s1.to_a
      assert_equal [ 2, 3 ], s1.set( [ 2, 3 ] )
      assert_equal [ 2, 3, 0 ], s1.to_a
      s2 = Hornetseye::Sequence( t, 3 ).new
      s2[] = [ 1, 2, 3 ]
      s1[] = s2
      assert_equal [ 1, 2, 3 ], s2.to_a
    end
  end

  def test_at_assign
    for t in @@types
      s = Hornetseye::Sequence( t, 3 ).new
      s[] = 0
      assert_equal [ 0, 0, 0 ], [ s.at( 0 ), s.at( 1 ), s.at( 2 ) ]
      assert_equal [ 1, 2, 3 ], [ s.assign( 0, 1 ),
                                  s.assign( 1, 2 ),
                                  s.assign( 2, 3 ) ]
      assert_equal [ 1, 2, 3 ], [ s.at( 0 ), s.at( 1 ), s.at( 2 ) ]
      assert_raise( ArgumentError ) { s.at 0, 0 }
      assert_nothing_raised { s.at }
      s = Hornetseye::Sequence( t, 3 ).new
      s[] = 0
      assert_equal [ 0, 0, 0 ], [ s[ 0 ], s[ 1 ], s[ 2 ] ]
      assert_equal [ 1, 2, 3 ], [ s[ 0 ] = 1, s[ 1 ] = 2, s[ 2 ] = 3 ]
      assert_equal [ 1, 2, 3 ], [ s[ 0 ], s[ 1 ], s[ 2 ] ]
      assert_raise( ArgumentError ) { s[ 0, 0 ] }
      assert_nothing_raised { s[] }
    end
  end

end
