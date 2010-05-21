require 'test/unit'
begin
  require 'rubygems'
rescue LoadError
end
Kernel::require 'multiarray'

class TC_Object < Test::Unit::TestCase

  O = Hornetseye::OBJECT
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
  end

  def test_inspect
    s = S.new O, 3
    s[ 0 ], s[ 1 ], s[ 2 ] = 1, 2, 3
    assert_equal "Sequence(OBJECT,3):\n[ 1, 2, 3 ]", s.inspect
  end

  def test_typecode
    assert_equal O, S.new( O, 3 ).typecode
  end

  def test_shape
    assert_equal [ 3 ], S[ 1, 2, 3 ].shape
  end

  def test_dimension
    assert_equal 1, S[ 1, 2, 3 ].dimension
  end

  def test_inject
    assert_equal 6, S[ 1, 2, 3 ].inject { |a,b| a + b }
  end

end
