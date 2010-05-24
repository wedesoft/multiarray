require 'test/unit'
begin
  require 'rubygems'
rescue LoadError
end
Kernel::require 'multiarray'

class TC_Int < Test::Unit::TestCase

  I = Hornetseye::INT
  U8 = Hornetseye::UBYTE
  S8 = Hornetseye::BYTE
  U16 = Hornetseye::USINT
  S16 = Hornetseye::SINT
  U32 = Hornetseye::UINT
  S32 = Hornetseye::INT

  def UI( bits )
    Hornetseye::INT Hornetseye::UNSIGNED, bits
  end

  def SI( bits )
    Hornetseye::INT Hornetseye::SIGNED, bits
  end


  def setup
  end

  def teardown
  end

  def test_int_inspect
    assert_equal 'UBYTE', U8.inspect
    assert_equal 'BYTE', S8.inspect
    assert_equal 'USINT', U16.inspect
    assert_equal 'SINT', S16.inspect
    assert_equal 'UINT', U32.inspect
    assert_equal 'INT', S32.inspect
  end

  def test_int_to_s
    assert_equal 'UBYTE', U8.to_s
    assert_equal 'BYTE', S8.to_s
    assert_equal 'USINT', U16.to_s
    assert_equal 'SINT', S16.to_s
    assert_equal 'UINT', U32.to_s
    assert_equal 'INT', S32.to_s
  end

  def test_int_default
    assert_equal 0, I.new[]
  end

  def test_int_typecode
    assert_equal I, I.typecode
  end

  def test_int_dimension
    assert_equal 0, I.dimension
  end

  def test_int_shape
    assert_equal [], I.shape
  end

  def test_inspect
    assert_equal 'INT(42)', I.new( 42 ).inspect
  end

  def test_marshal
    assert_equal I.new( 42 ), Marshal.load( Marshal.dump( I.new( 42 ) ) )
  end

  def test_typecode
    assert_equal I, I.new.typecode
  end

  def test_dimension
    assert_equal 0, I.new.dimension
  end

  def test_shape
    assert_equal [], I.new.shape
  end

  def test_at_assign
    i = I.new 42
    assert_equal 42, i[]
    assert_equal 3, i[] = 3
    assert_equal 3, i[]
  end

  def test_equal
    assert_not_equal I.new( 3 ), I.new( 4 )
    assert_equal I.new( 3 ), I.new( 3 )
  end

  def test_inject
    assert_equal 2, I.new( 2 ).inject { |a,b| a + b }[]
    assert_equal 3, I.new( 2 ).inject( 1 ) { |a,b| a + b }[]
  end

  def test_zero
    assert I.new( 0 ).zero?[]
    assert !I.new( 3 ).zero?[]
  end

  def test_negate
    assert_equal I.new( -5 ), -I.new( 5 )
  end

  def test_plus
    assert_equal I.new( 3 + 5 ), I.new( 3 ) + I.new( 5 )
  end

end

