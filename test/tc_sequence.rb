require 'test/unit'
begin
  require 'rubygems'
rescue LoadError
end
Kernel::require 'multiarray'

class TC_Sequence < Test::Unit::TestCase

  O = Hornetseye::OBJECT
  S = Hornetseye::Sequence

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

  def S( *args )
    Hornetseye::Sequence *args
  end

  def test_default
    assert_equal [ nil, nil, nil ], S( O, 3 ).new.to_a
  end

  def test_sequence_inspect
    assert_equal 'Sequence.object(3)', S( O, 3 ).inspect
  end

  def test_sequence_to_s
    assert_equal 'Sequence.object(3)', S( O, 3 ).to_s
  end

  def test_sequence_assign
    assert_equal [ :a, :b, :c ], S[ :a, :b, :c ].to_a
  end

  def test_inspect
    assert_equal "Sequence.object(3):\n[ :a, :b, :c ]", S[ :a, :b, :c ].inspect
  end

  def test_to_s
    # !!!
  end

  def test_at_assign
    s = S.new O, 3
    for i in 0 ... 3
      assert_equal i + 1, s[ i ] = i + 1
    end
    assert_equal [ 1, 2, 3 ], s[].to_a
    for i in 0 ... 3
      assert_equal i + 1, s[ i ]
    end
  end

  def test_equal
    # !!!
  end

  def test_negate
    s = S[ 1, 2, 3 ]
    assert_equal [ -1, -2, -3 ], ( -s ).to_a
  end

  def test_lazy
    s = S[ 1, 2, 3 ]
    u = lazy { -s }
    assert_equal 'Sequence.object(3):<delayed>', u.inspect
    assert_equal [ -1, -2, -3 ], u.force.to_a
    u = lazy { --s }
    assert_equal 'Sequence.object(3):<delayed>', u.inspect
    assert_equal [ 1, 2, 3 ], u.force.to_a
    u = -lazy { -s }
    assert_equal "Sequence.object(3):\n[ 1, 2, 3 ]", u.inspect
    assert_equal [ 1, 2, 3 ], u.to_a
    u = lazy { -lazy { -s } }
    assert_equal 'Sequence.object(3):<delayed>', u.inspect
    assert_equal [ 1, 2, 3 ], u.force.to_a
    u = eager { lazy { -s } }
    assert_equal 'Sequence.object(3):<delayed>', u.inspect
    assert_equal [ -1, -2, -3 ], u.force.to_a
    u = lazy { eager { -lazy { -s } } }
    assert_equal "Sequence.object(3):\n[ 1, 2, 3 ]", u.inspect
    assert_equal [ 1, 2, 3 ], u.to_a
  end

end
