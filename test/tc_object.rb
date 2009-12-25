require 'test/unit'
begin
  require 'rubygems'
rescue LoadError
end
Kernel::require 'multiarray'

class TC_Object < Test::Unit::TestCase

  def setup
    @@t = Hornetseye::OBJECT
  end

  def teardown
    @@t = nil
  end

  def test_object_default
    assert_nil @@t.default
  end

  def test_int_to_s
    assert_equal 'OBJECT', @@t.to_s
  end

  def test_int_inspect
    assert_equal @@t.to_s, @@t.inspect
  end

  def test_storage_size
    assert_equal 1, @@t.delegate.storage_size
  end

  def test_typecode
    assert_equal @@t, @@t.typecode
  end

  def test_shape
    assert_equal [], @@t.shape
  end

  def test_size
    assert_equal 1, @@t.size
  end

  def test_to_s
    assert_equal '42', @@t.new( 42 ).to_s
  end

  def test_inspect
    assert_equal "OBJECT(42)", @@t.new( 42 ).inspect
  end

  def test_get_set
    i = @@t.new nil
    assert_nil i.get
    assert_equal 42, i.set( 42 )
    assert_equal 42, i.get
    assert_nil i.set
    assert_nil i.get
  end

  def test_at_assign
    i = @@t.new nil
    assert_nil i.at
    assert_equal 42, i.assign( 42 )
    assert_equal 42, i.at
    assert_raise( ArgumentError ) { i.at 0 }
    assert_raise( ArgumentError ) { i.assign 0, nil }
    i = @@t.new nil
    assert_nil i[]
    assert_equal 42, i[] = 42 
    assert_equal 42, i[]
    assert_raise( ArgumentError ) { i[ 0 ] }
    assert_raise( ArgumentError ) { i[ 0 ] = nil }
  end

end
