# multiarray - Lazy multi-dimensional arrays for Ruby
# Copyright (C) 2010 Jan Wedekind
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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

  def I( *args )
    Hornetseye::INT *args
  end

  def UI( bits )
    I Hornetseye::UNSIGNED, bits
  end

  def SI( bits )
    I Hornetseye::SIGNED, bits
  end

  def sum( *args, &action )
    Hornetseye::sum *args, &action
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

  def test_int_indgen
    assert_equal 0, I.indgen
    assert_equal 1, I.indgen( 1 )
    assert_equal 1, I.indgen( 1, 2 )
  end

  def test_int_typecode
    assert_equal I, I.typecode
  end

  def test_int_dimension
    assert_equal 0, I.dimension
  end
!
  def test_int_shape
    assert_equal [], I.shape
  end

  def test_int_size
    assert_equal 1, I.size
  end

  def test_inspect
    assert_equal 'INT(42)', I( 42 ).inspect
  end

  def test_marshal
    assert_equal I( 42 ), Marshal.load( Marshal.dump( I( 42 ) ) )
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

  def test_size
    assert_equal 1, I.new.size
  end

  def test_at_assign
    i = I 42
    assert_equal 42, i[]
    assert_equal 3, i[] = 3
    assert_equal 3, i[]
  end

  def test_equal
    assert_not_equal I( 3 ), I( 4 )
    assert_equal I( 3 ), I( 3 )
  end

  def test_r_g_b
    assert_equal I( 3 ), I( 3 ).r
    assert_equal I( 3 ), I( 3 ).g
    assert_equal I( 3 ), I( 3 ).b
  end

  def test_inject
    assert_equal 2, I( 2 ).inject { |a,b| a + b }[]
    assert_equal 3, I( 2 ).inject( 1 ) { |a,b| a + b }[]
  end

  def test_not
    assert !I( 0 ).not[]
    assert !I( 3 ).not[]
  end

  def test_sum
    assert_equal 3, sum { || 3 }
  end

  def test_zero
    assert I( 0 ).zero?[]
    assert !I( 3 ).zero?[]
  end

  def test_nonzero
    assert !I( 0 ).nonzero?[]
    assert I( 3 ).nonzero?[]
  end

  def test_bitwise_not
    assert_equal I( -3 ), ~I( 2 )
  end

  def test_bitwise_and
    assert_equal I( 2 ), I( 3 ) & I( 6 )
  end

  def test_bitwise_or
    assert_equal I( 7 ), I( 3 ) | I( 6 )
  end

  def test_bitwise_xor
    assert_equal I( 1 ), I( 3 ) ^ I( 2 )
  end

  def test_shl
    assert_equal I( 4 ), I( 2 ) << I( 1 )
  end

  def test_shr
    assert_equal I( 2 ), I( 4 ) >> I( 1 )
  end

  def test_negate
    assert_equal I( -5 ), -I( 5 )
  end

  def test_plus
    assert_equal I( 3 + 5 ), I( 3 ) + I( 5 )
  end

  def test_major
    assert_equal I( 4 ), I( 3 ).major( I( 4 ) )
    assert_equal I( 5 ), I( 5 ).major( I( 3 ) )
  end

  def test_minor
    assert_equal I( 3 ), I( 3 ).minor( I( 4 ) )
    assert_equal I( 4 ), I( 5 ).minor( I( 4 ) )
  end

end

