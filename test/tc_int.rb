require 'test/unit'
require 'multiarray'

class TC_Int < Test::Unit::TestCase

  def setup
    @@types = [ Hornetseye::UBYTE,
                Hornetseye::BYTE,
                Hornetseye::USINT,
                Hornetseye::SINT,
                Hornetseye::UINT,
                Hornetseye::INT,
                Hornetseye::ULONG,
                Hornetseye::LONG ]
  end

  def teardown
    @@types = nil
  end

  def test_int_default
    for t in @@types
      assert_equal 0, t.default
    end
  end

  def test_int_to_s
    assert_equal 'UBYTE', Hornetseye::UBYTE.to_s
    assert_equal 'BYTE' , Hornetseye::BYTE.to_s
    assert_equal 'USINT', Hornetseye::USINT.to_s
    assert_equal 'SINT' , Hornetseye::SINT.to_s
    assert_equal 'UINT' , Hornetseye::UINT.to_s
    assert_equal 'INT'  , Hornetseye::INT.to_s
    assert_equal 'ULONG', Hornetseye::ULONG.to_s
    assert_equal 'LONG' , Hornetseye::LONG.to_s
  end

  def test_int_inspect
    for t in @@types
      assert_equal t.to_s, t.inspect
    end
  end

  def test_bytesize
    for i in [ 8, 16, 32, 64 ]
      assert_equal i, 8 * Hornetseye::INT( i, Hornetseye::UNSIGNED ).bytesize
      assert_equal i, 8 * Hornetseye::INT( i, Hornetseye::SIGNED   ).bytesize
    end
  end

  def test_typecode
    for t in @@types
      assert_equal t, t.typecode
    end
  end

  def test_shape
    for t in @@types
      assert_equal [], t.shape
    end
  end

  def test_size
    for t in @@types
      assert_equal 1, t.size
    end
  end

  def test_to_s
    for t in @@types
      assert_equal '42', t.new( 42 ).to_s
    end
  end

  def test_inspect
    for t in @@types
      assert_equal "#{t.inspect}(42)", t.new( 42 ).inspect
    end
  end

  def test_get_set
    for t in @@types
      i = t.new 0
      assert_equal 0, i.get
      assert_equal 42, i.set( 42 )
      assert_equal 42, i.get
      assert_equal 0, i.set
      assert_equal 0, i.get
    end
  end

  def test_at_assign
    for t in @@types
      i = t.new 0
      assert_equal 0, i.at
      assert_equal 42, i.assign( 42 )
      assert_equal 42, i.at
      assert_raise( ArgumentError ) { i.at 0 }
      assert_raise( ArgumentError ) { i.assign 0, 0 }
      i = t.new 0
      assert_equal 0, i[]
      assert_equal 42, i[] = 42 
      assert_equal 42, i[]
      assert_raise( ArgumentError ) { i[ 0 ] }
      assert_raise( ArgumentError ) { i[ 0 ] = 0 }
    end
  end

  def test_op
    for t in @@types
      i = t.new 1
      assert_equal 3, i.op( 2 ) { |x| set get + x }.get
    end
  end

end
