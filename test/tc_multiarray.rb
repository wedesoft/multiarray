require 'test/unit'
begin
  require 'rubygems'
rescue LoadError
end
Kernel::require 'multiarray'

class TC_MultiArray < Test::Unit::TestCase

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

  def test_default
    for t in @@types
      m = Hornetseye::MultiArray( t, 3, 2 ).default
      assert_equal [ [ 0, 0, 0 ], [ 0, 0, 0 ] ], m.to_a
    end
  end

  def test_multiarray_new
    for t in @@types
      m = Hornetseye::MultiArray.new t, 3, 2
      m.set
      assert_equal [ [ 0, 0, 0 ], [ 0, 0, 0 ] ], m.to_a
    end
  end

  def test_multiarray_to_s
    for t in @@types
      assert_equal "MultiArray.#{t.to_s.downcase}(3,2)",
                   Hornetseye::MultiArray( t, 3, 2 ).to_s
    end
  end

  def test_multiarray_inspect
    for t in @@types
      assert_equal "MultiArray.#{t.inspect.downcase}(3,2)",
                   Hornetseye::MultiArray( t, 3, 2 ).inspect
    end
  end

  def test_storage_size
    for t in @@types
      assert_equal t.delegate.storage_size * 3 * 2,
                   Hornetseye::MultiArray( t, 3, 2 ).delegate.storage_size
    end
  end

  def test_typecode
    for t in @@types
      assert_equal t, Hornetseye::MultiArray( t, 3, 2 ).new.typecode
    end
  end

  def test_empty
    for t in @@types
      assert Hornetseye::MultiArray( t, 0, 0 ).new.empty?
      assert Hornetseye::MultiArray( t, 0, 2 ).new.empty?
      assert Hornetseye::MultiArray( t, 3, 0 ).new.empty?
      assert !Hornetseye::MultiArray( t, 3, 2 ).new.empty?
    end
  end

  def test_shape
    for t in @@types
      assert_equal [ 3, 2 ], Hornetseye::MultiArray( t, 3, 2 ).new.shape
    end
  end

  def test_size
    for t in @@types
      assert_equal 3 * 2, Hornetseye::MultiArray( t, 3, 2 ).new.size
    end
  end

end

