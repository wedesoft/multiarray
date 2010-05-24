require 'test/unit'
begin
  require 'rubygems'
rescue LoadError
end
Kernel::require 'multiarray'

class TC_Sequence < Test::Unit::TestCase

  O = Hornetseye::OBJECT
  B = Hornetseye::BOOL
  I = Hornetseye::INT
  S = Hornetseye::Sequence

  def S( *args )
    Hornetseye::Sequence *args
  end

  def setup
  end

  def teardown
  end

  def test_sequence_inspect
    assert_equal 'Sequence(OBJECT,3)', S( O, 3 ).inspect
  end
  
  def test_sequence_to_s
    assert_equal 'Sequence(OBJECT,3)', S( O, 3 ).to_s
  end

  def test_sequence_default
    assert_equal [ O.default ] * 3, S( O, 3 ).default.to_a
  end

  def test_sequence_at
    assert_equal [ 1, 2, 3 ], S[ 1, 2, 3 ].to_a
    assert_equal O, S[ :a ].typecode
    assert_equal B, S[ false, true ].typecode
    assert_equal I, S[ -2 ** 31, 2 ** 31 - 1 ].typecode
  end

  def test_sequence_typecode
    assert_equal O, S( O, 3 ).typecode
  end

  def test_sequence_dimension
    assert_equal 1, S( O, 3 ).dimension
  end

  def test_sequence_shape
    assert_equal [ 3 ], S( O, 3 ).shape
  end

  def test_inspect
    assert_equal "Sequence(OBJECT,3):\n[ :a, 2, 3 ]", S[ :a, 2, 3 ].inspect
  end

  def test_typecode
    assert_equal O, S.new( O, 3 ).typecode
  end

  def test_dimension
    assert_equal 1, S[ 1, 2, 3 ].dimension
  end

  def test_shape
    assert_equal [ 3 ], S[ 1, 2, 3 ].shape
  end

  def test_at_assign
    s = S.new O, 3
    for i in 0 ... 3
      assert_equal i + 1, s[ i ] = i + 1
    end
    for i in 0 ... 3
      assert_equal i + 1, s[ i ]
    end
  end

  def test_equal
    assert_equal S[ 2, 3, 5 ], S[ 2, 3, 5 ]
    assert_not_equal S[ 2, 3, 5 ], S[ 2, 3, 7 ]
    #assert_not_equal S[ 2, 3, 5 ], S[ 2, 3 ] # !!!
    #assert_not_equal S[ 2, 3, 5 ], S[ 2, 3, 5, 7 ]
    assert_not_equal S[ 2, 2, 2 ], 2
  end

  def test_inject
    assert_equal 6, S[ 1, 2, 3 ].inject { |a,b| a + b }
    assert_equal 10, S[ 1, 2, 3 ].inject( 4 ) { |a,b| a + b }
  end

  def test_zero
    assert_equal S[ false, true, false ], S[ -1, 0, 1 ].zero?
  end

  def test_negate
    assert_equal S[ -1, 2, -3 ], -S[ 1, -2, 3 ]
  end

  def test_plus
    assert_equal S[ 2, 3, 5 ], S[ 1, 2, 4 ] + 1
    assert_equal S[ 2, 3, 5 ], 1 + S[ 1, 2, 4 ]
    assert_equal S[ 2, 3, 5 ], S[ 1, 2, 3 ] + S[ 1, 1, 2 ]
  end

end
