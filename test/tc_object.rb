require 'test/unit'
begin
  require 'rubygems'
rescue LoadError
end
Kernel::require 'multiarray'

class TC_Object < Test::Unit::TestCase

  O = Hornetseye::OBJECT

  def setup
  end

  def teardown
  end

  def test_object_inspect
    assert_equal 'OBJECT', O.inspect
  end

  def test_object_to_s
    assert_equal 'OBJECT', O.to_s
  end

  def test_object_default
    assert_nil O.new[]
  end

  def test_inspect
    assert_equal 'OBJECT(42)', O.new( 42 ).inspect
  end

  def test_marshal
    assert_equal O.new( 42 ), Marshal.load( Marshal.dump( O.new( 42 ) ) )
  end

  def test_at_assign
    o = O.new 3
    assert_equal 3, o[]
    assert_equal 42, o[] = 42
    assert_equal 42, o[]
  end

  def test_equal
    assert_not_equal O.new( 3 ), O.new( 4 )
    assert_equal O.new( 3 ), O.new( 3 )
  end

  def test_inject
    assert_equal 2, OBJECT.new( 2 ).inject { |a,b| a + b }[]
    assert_equal 3, OBJECT.new( 2 ).inject( 1 ) { |a,b| a + b }[]
  end

  def test_negate
    assert_equal O.new( -5 ), -O.new( 5 )
  end

  def test_plus
    assert_equal O.new( 3 + 5 ), O.new( 3 ) + O.new( 5 )
  end

end
