require 'test/unit'
begin
  require 'rubygems'
rescue LoadError
end
Kernel::require 'multiarray'

class TC_Bool < Test::Unit::TestCase

  B = Hornetseye::BOOL

  def setup
  end

  def teardown
  end

  def test_bool_inspect
    assert_equal 'BOOL', B.inspect
  end

  def test_bool_to_s
    assert_equal 'BOOL', B.to_s
  end

  def test_bool_default
    assert_equal false, B.new[]
  end

  def test_bool_typecode
    assert_equal B, B.typecode
  end

  def test_bool_dimension
    assert_equal 0, B.dimension
  end

  def test_bool_shape
    assert_equal [], B.shape
  end

  def test_inspect
    assert_equal 'BOOL(true)', B.new( true ).inspect
  end

  def test_marshal
    assert_equal B.new( true ), Marshal.load( Marshal.dump( B.new( true ) ) )
  end

  def test_typecode
    assert_equal B, B.new.typecode
  end

  def test_dimension
    assert_equal 0, B.new.dimension
  end

  def test_shape
    assert_equal [], B.new.shape
  end

  def test_at_assign
    b = B.new false
    assert !b[]
    assert b[] = true
    assert b[]
  end

  def test_equal
    assert_equal B.new( false ), B.new( false )
    assert_not_equal B.new( false ), B.new( true )
    assert_not_equal B.new( true ), B.new( false )
    assert_equal B.new( true ), B.new( true )
  end

  def test_inject
    assert B.new( true ).inject { |a,b| a.and b }[]
    assert !B.new( false ).inject( true ) { |a,b| a.and b }[]
    assert !B.new( true ).inject( false ) { |a,b| a.and b }[]
  end

  def test_zero
  end

  def test_not
    assert_equal B.new( true ), B.new( false ).not
    assert_equal B.new( false ), B.new( true ).not
  end

  def test_and
    assert_equal B.new( false ), B.new( false ).and( B.new( false ) )
    assert_equal B.new( false ), B.new( false ).and( B.new( true ) )
    assert_equal B.new( false ), B.new( true ).and( B.new( false ) )
    assert_equal B.new( true ), B.new( true ).and( B.new( true ) )
  end

  def test_or
    assert_equal B.new( false ), B.new( false ).or( B.new( false ) )
    assert_equal B.new( true ), B.new( false ).or( B.new( true ) )
    assert_equal B.new( true ), B.new( true ).or( B.new( false ) )
    assert_equal B.new( true ), B.new( true ).or( B.new( true ) )
  end

end
