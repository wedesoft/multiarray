require 'test/unit'
begin
  require 'rubygems'
rescue LoadError
end
Kernel::require 'multiarray'

class TC_Object < Test::Unit::TestCase

  O = Hornetseye::OBJECT

  def S( *args )
    Hornetseye::Sequence *args
  end

  def setup
  end

  def teardown
  end

  def test_sequence_default
    assert_equal [ nil, nil, nil ], S( O, 3 ).default.to_a
  end

  def test_sequence_inspect
    assert_equal 'Sequence(OBJECT,3)', S( O, 3 ).inspect
  end
  
  def test_sequence_to_s
    assert_equal 'Sequence(OBJECT,3)', S( O, 3 ).to_s
  end

end
