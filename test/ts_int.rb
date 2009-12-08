require 'test/unit'
require 'multiarray'

class TC_Int < Test::Unit::TestCase

  def setup
    @@types = [ MultiArray::UBYTE,
                MultiArray::BYTE,
                MultiArray::USINT,
                MultiArray::SINT,
                MultiArray::UINT,
                MultiArray::INT,
                MultiArray::ULONG,
                MultiArray::LONG ]
  end

  def teardown
    @@types = nil
  end

  def test_int_to_s
    assert_equal 'UBYTE', MultiArray::UBYTE.to_s
    assert_equal 'BYTE' , MultiArray::BYTE.to_s
    assert_equal 'USINT', MultiArray::USINT.to_s
    assert_equal 'SINT' , MultiArray::SINT.to_s
    assert_equal 'UINT' , MultiArray::UINT.to_s
    assert_equal 'INT'  , MultiArray::INT.to_s
    assert_equal 'ULONG', MultiArray::ULONG.to_s
    assert_equal 'LONG' , MultiArray::LONG.to_s
  end

  def test_int_inspect
    @@types.each do |t|
      assert_equal t.to_s, t.inspect
    end
  end

  def test_to_s
    @@types.each do |t|
      assert_equal '42', t.new( 42 ).to_s
    end
  end

  def test_inspect
    @@types.each do |t|
      assert_equal "#{t.inspect}(42)", t.new( 42 ).inspect
    end
  end

  def test_bytesize
    for i in [ 8, 16, 32, 64 ]
      assert_equal i, 8 * MultiArray::INT( i, MultiArray::UNSIGNED ).bytesize
      assert_equal i, 8 * MultiArray::INT( i, MultiArray::SIGNED   ).bytesize
    end
  end

  def test_typecode
    @@types.each do |t|
      assert_equal t, t.typecode
    end
  end

  def test_get_set
    @@types.each do |t|
      i = t.new 0
      assert_equal 0, i.get
      assert_equal 42, i.set( 42 )
      assert_equal 42, i.get
    end
  end

end
