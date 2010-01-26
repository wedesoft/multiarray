require 'test/unit'
begin
  require 'rubygems'
rescue LoadError
end
Kernel::require 'multiarray'

class TC_MultiArray < Test::Unit::TestCase

  O = Hornetseye::OBJECT
  M = Hornetseye::MultiArray

  def lazy( &action )
    Hornetseye::lazy &action
  end

  def eager( &action )
    Hornetseye::eager &action
  end

  def setup
  end

  def teardown
  end

  def M( *args )
    Hornetseye::MultiArray *args
  end

  def test_default
    assert_equal [ [ nil ] * 3 ] * 2, M( O, 3, 2 ).new.to_a
  end

  def test_multiarray_inspect
    assert_equal 'MultiArray.object(3,2)', M( O, 3, 2 ).inspect
  end

  def test_multiarray_to_s
    assert_equal 'MultiArray.object(3,2)', M( O, 3, 2 ).to_s
  end

  def test_multiarray_assign
    assert_equal [ [ :a, :b, :c ], [ :d, :e, :f ] ],
                 M[ [ :a, :b, :c ], [ :d, :e, :f ] ].to_a
    assert_equal [ [ :a, nil ], [ :b, :c ] ],
                 M[ [ :a ], [ :b, :c ] ].to_a
    assert_equal [ [ :a, :b ], [ :c, :c ] ],
                 M[ [ :a, :b ], :c ].to_a
  end

  def test_inspect
    assert_equal "MultiArray.object(3,2):\n" + 
                 "[ [ :a, :b, :c ],\n  [ :d, :e, :f ] ]",
                 M[ [ :a, :b, :c ], [ :d, :e, :f ] ].inspect
  end

  def test_to_s
    # !!!
  end

  def test_at_assign
    m = M.new O, 3, 2
    for j in 0 ... 2
      for i in 0 ... 3
        assert_equal i + j * 3 + 1, m[ j ][ i ] = i + j * 3 + 1
      end
    end
    for j in 0 ... 2
      for i in 0 ... 3
        assert_equal i + j * 3 + 1, m[ j ][ i ]
      end
    end
    assert_equal [ 4, 5, 6 ], m[ 1 ].to_a
    assert_equal 7, m[ 1 ] = 7
    assert_equal [ [ 1, 2, 3 ], [ 7, 7, 7 ] ], m.to_a
  end

  def test_equal
    # !!!
  end

  def test_negate
    m = M[ [ 1, 2, 3 ], [ 4, 5, 6 ] ]
    assert_equal [ [ -1, -2, -3 ], [ -4, -5, -6 ] ], ( -m ).to_a
  end

  def test_lazy
    m = M[ [ 1, 2, 3 ], [ 4, 5, 6 ] ]
    u = lazy { -m }
    assert_equal 'MultiArray.object(3,2):<delayed>', u.inspect
    assert_equal [ [ -1, -2, -3 ], [ -4, -5, -6 ] ], u.force.to_a
    u = lazy { --m }
    assert_equal 'MultiArray.object(3,2):<delayed>', u.inspect
    assert_equal [ [ 1, 2, 3 ], [ 4, 5, 6 ] ], u.force.to_a
    u = -lazy { -m }
    assert_equal "MultiArray.object(3,2):\n[ [ 1, 2, 3 ],\n  [ 4, 5, 6 ] ]",
                 u.inspect
    assert_equal [ [ 1, 2, 3 ], [ 4, 5, 6 ] ], u.to_a
    u = lazy { -lazy { -m } }
    assert_equal 'MultiArray.object(3,2):<delayed>', u.inspect
    assert_equal [ [ 1, 2, 3 ], [ 4, 5, 6 ] ], u.force.to_a
    u = eager { lazy { -m } }
    assert_equal 'MultiArray.object(3,2):<delayed>', u.inspect
    assert_equal [ [ -1, -2, -3 ], [ -4, -5, -6 ] ], u.force.to_a
    u = lazy { eager { -lazy { -m } } }
    assert_equal "MultiArray.object(3,2):\n[ [ 1, 2, 3 ],\n  [ 4, 5, 6 ] ]",
      u.inspect
    assert_equal [ [ 1, 2, 3 ], [ 4, 5, 6 ] ], u.to_a
  end

end
