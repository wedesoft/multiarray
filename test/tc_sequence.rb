require 'test/unit'
begin
  require 'rubygems'
rescue LoadError
end
Kernel::require 'multiarray'

class TC_Sequence < Test::Unit::TestCase

  O   = Hornetseye::OBJECT
  U8  = Hornetseye::UBYTE
  S8  = Hornetseye::BYTE
  U16 = Hornetseye::USINT
  S16 = Hornetseye::SINT
  U32 = Hornetseye::UINT
  S32 = Hornetseye::INT
  U64 = Hornetseye::ULONG
  S64 = Hornetseye::LONG
  S   = Hornetseye::Sequence

  T = [ O, U8, S8, U16, S16, U32, S32 ]
  INSPECT = {
    O => 'OBJECT',
    U8 => 'UBYTE', S8 => 'BYTE',
    U16 => 'USINT', S16 => 'SINT',
    U32 => 'UINT', S32 => 'INT'
  }
  SIGNED = {
    O => true,
    U8 => false, S8 => true,
    U16 => false, S16 => true,
    U32 => false, S32 => true
  }

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
    T.each do |t|
      s = S( t, 3 ).new
      s[] = t.new[]
      assert_equal [ t.new[] ] * 3, s.to_a
    end
  end

  def test_sequence_inspect
    T.each do |t|
      assert_equal "Sequence.#{t.inspect.downcase}(3)", S( t, 3 ).inspect
    end
  end

  def test_sequence_to_s
    T.each do |t|
      assert_equal "Sequence.#{t.to_s.downcase}(3)", S( t, 3 ).to_s
    end
  end

  def test_sequence_assign
    assert_equal [ :a, :b, :c ], S[ :a, :b, :c ].to_a
    assert_equal [ :a, :b, [ :c ] ], S[ :a, :b, [ :c ] ].to_a
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
    s = S[ 1, 2, 3 ].to_type O
    assert_equal [ -1, -2, -3 ], ( -s ).to_a
  end

  def test_plus
    s = S[ 1, 2, 3 ].to_type O
    assert_equal [ 2, 4, 6 ], ( s + s ).to_a
    assert_equal [ 2, 3, 4 ], ( s + 1 ).to_a
    assert_equal [ 2, 3, 4 ], ( 1 + s ).to_a
  end

  def test_lazy_unary
    s = S[ 1, 2, 3 ].to_type O
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
