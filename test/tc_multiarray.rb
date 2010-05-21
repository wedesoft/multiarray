require 'test/unit'
begin
  require 'rubygems'
rescue LoadError
end
Kernel::require 'multiarray'

class TC_MultiArray < Test::Unit::TestCase

  O = Hornetseye::OBJECT
  M = Hornetseye::MultiArray

  def M( *args )
    Hornetseye::MultiArray *args
  end

  def setup
  end

  def teardown
  end

  def test_multiarray_inspect
    assert_equal 'MultiArray(OBJECT,3,2)', M( O, 3, 2 ).inspect
  end

  def test_multiarray_to_s
    assert_equal 'MultiArray(OBJECT,3,2)', M( O, 3, 2 ).to_s
  end

  def test_multiarray_default
    assert_equal [ [ O.default ] * 3 ] * 2, M( O, 3, 2 ).default.to_a
  end

  def test_multiarray_at
    assert_equal [ [ 1, 2, 3 ], [ 4, 5, 6 ] ],
                 M[ [ 1, 2, 3 ], [ 4, 5, 6 ] ].to_a
  end

  def test_multiarray_typecode
    assert_equal O, M( O, 3, 2 ).typecode
  end

  def test_multiarray_dimension
    assert_equal 2, M( O, 3, 2 ).dimension
  end

  def test_multiarray_shape
    assert_equal [ 3, 2 ], M( O, 3, 2 ).shape
  end

  def test_inspect
    assert_equal "MultiArray(OBJECT,3,2):\n[ [ :a, 2, 3 ],\n  [ 4, 5, 6 ] ]",
                 M[ [ :a, 2, 3 ], [ 4, 5, 6 ] ].inspect
  end

  def test_typecode
    assert_equal O, M( O, 3, 2 ).new.typecode
  end

  def test_dimension
    assert_equal 2, M( O, 3, 2 ).new.dimension
  end

  def test_shape
    assert_equal [ 3, 2 ], M( O, 3, 2 ).new.shape
  end

  def test_at_assign
    m = M.new O, 3, 2
    for j in 0 ... 2
      for i in 0 ... 3
        assert_equal j * 3 + i + 1, m[ j ][ i ] = j * 3 + i + 1
        assert_equal j * 3 + i + 1, m[ i, j ] = j * 3 + i + 1
      end
    end
    for j in 0 ... 2
      for i in 0 ... 3
        assert_equal j * 3 + i + 1, m[ j ][ i ]
        assert_equal j * 3 + i + 1, m[ i, j ]
      end
    end
  end

  def test_equal
    assert_equal M[ [ 1, 2, 3 ], [ 4, 5, 6 ] ], M[ [ 1, 2, 3 ], [ 4, 5, 6 ] ]
    assert_not_equal M[ [ 1, 2, 3 ], [ 4, 5, 6 ] ],
                     M[ [ 1, 2, 3 ], [ 4, 6, 5 ] ]
    # !!!
    assert_not_equal M[ [ 1, 1 ], [ 1, 1 ] ], 1
    assert_not_equal M[ [ 1, 1 ], [ 1, 1 ] ], M[ 1, 1 ]
  end

end
