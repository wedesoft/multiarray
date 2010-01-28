require 'test/unit'
begin
  require 'rubygems'
rescue LoadError
end
Kernel::require 'multiarray'

class TC_Int < Test::Unit::TestCase

  U8  = Hornetseye::UBYTE
  S8  = Hornetseye::BYTE
  U16 = Hornetseye::USINT
  S16 = Hornetseye::SINT
  U32 = Hornetseye::UINT
  S32 = Hornetseye::INT
  U64 = Hornetseye::ULONG
  S64 = Hornetseye::LONG

  T = [ U8, S8, U16, S16, U32, S32 ]
  INSPECT = {
    U8 => 'UBYTE', S8 => 'BYTE',
    U16 => 'USINT', S16 => 'SINT',
    U32 => 'UINT', S32 => 'INT'
  }
  SIGNED = {
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

  def test_int_default
    T.each { |t| assert_equal 0, t.new[] }
  end


  def test_int_inspect
    T.each { |t| assert_equal INSPECT[ t ], t.inspect }
  end

  def test_int_to_s
    T.each { |t| assert_equal INSPECT[ t ], t.to_s }
  end

  def test_inspect
    T.each { |t| assert_equal "#{t}(42)", t.new( 42 ).inspect }
  end

  def test_to_s
    T.each { |t| assert_equal '42', t.new( 42 ).to_s }
  end

  def test_marshal
    T.each do |t|
      assert_equal t.new( 42 ),
                   Marshal.load( Marshal.dump( t.new( 42 ) ) )
    end
  end

  def test_at_assign
    T.each do |t|
      i = t.new 3
      assert_equal 3, i[]
      assert_equal 42, i[] = 42
      assert_equal 42, i[]
    end
  end

  def test_equal
    T.each do |t1|
      T.each do |t2|
        assert_not_equal t1.new( 3 ), t2.new( 4 )
        assert_equal t1 == t2, t1.new( 3 ) == t2.new( 3 )
      end
    end
  end

  def test_negate
    T.select { |t| SIGNED[ t ] }.each do |t|
      assert_equal t.new( -5 ), -t.new( 5 )
    end
  end

  def test_plus
    T.each do |t1|
      T.each do |t2|
        assert_equal 5, ( t1.new( 3 ) + t2.new( 2 ) )[]
      end
    end
  end

  def test_lazy_unary
    T.select { |t| SIGNED[ t ] }.each do |t|
      i = lazy { -t.new( 3 ) }
      assert_not_equal t.new( -3 ), i
      assert_equal "#{t}(<delayed>)", i.inspect
      assert_equal t.new( -3 ), i.force
      i = lazy { --t.new( 3 ) }
      assert_equal "#{t}(<delayed>)", i.inspect
      assert_equal t.new( 3 ), i.force
      i = -lazy { -t.new( 3 ) }
      assert_equal t.new( 3 ), i
      i = lazy { -lazy { -t.new( 3 ) } }
      assert_equal "#{t}(<delayed>)", i.inspect
      assert_equal t.new( 3 ), i.force
      i = eager { lazy { -t.new( 3 ) } }
      assert_equal "#{t}(<delayed>)", i.inspect
      i = lazy { eager { -lazy { -t.new( 3 ) } } }
      assert_equal t.new( 3 ), i
    end
  end

  def test_lazy_binary
    a = U16.new 3
    b = S8.new -5
    i = lazy { a + b }
    assert_not_equal a + b, i
    assert_equal 'SINT(<delayed>)', i.inspect
    assert_equal S16.new( -2 ), i.force
    assert_equal S32.new( -1 ), i + S32.new( 1 )
    assert_equal S32.new( -1 ), S32.new( 1 ) + i
  end


end
