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

class TC_RGB < Test::Unit::TestCase

  BYTERGB   = Hornetseye::BYTERGB
  UBYTERGB  = Hornetseye::UBYTERGB
  SINTRGB   = Hornetseye::SINTRGB
  USINTRGB  = Hornetseye::USINTRGB
  INTRGB    = Hornetseye::INTRGB
  UINTRGB   = Hornetseye::UINTRGB
  LONGRGB   = Hornetseye::LONGRGB
  ULONGRGB  = Hornetseye::ULONGRGB
  SFLOATRGB = Hornetseye::SFLOATRGB
  DFLOATRGB = Hornetseye::DFLOATRGB

  def RGB( *args )
    Hornetseye::RGB *args
  end

  def INTRGB( value )
    Hornetseye::INTRGB value
  end

  def sum( *args, &action )
    Hornetseye::sum *args, &action
  end

  def setup
  end

  def teardown
  end

  def test_rgb_inspect
    assert_equal 'BYTERGB', BYTERGB.inspect
    assert_equal 'UBYTERGB', UBYTERGB.inspect
    assert_equal 'SINTRGB', SINTRGB.inspect
    assert_equal 'USINTRGB', USINTRGB.inspect
    assert_equal 'INTRGB', INTRGB.inspect
    assert_equal 'UINTRGB', UINTRGB.inspect
    assert_equal 'LONGRGB', LONGRGB.inspect
    assert_equal 'ULONGRGB', ULONGRGB.inspect
    assert_equal 'SFLOATRGB', SFLOATRGB.inspect
    assert_equal 'DFLOATRGB', DFLOATRGB.inspect
  end

  def test_rgb_to_s
    assert_equal 'BYTERGB', BYTERGB.to_s
    assert_equal 'UBYTERGB', UBYTERGB.to_s
    assert_equal 'SINTRGB', SINTRGB.to_s
    assert_equal 'USINTRGB', USINTRGB.to_s
    assert_equal 'INTRGB', INTRGB.to_s
    assert_equal 'UINTRGB', UINTRGB.to_s
    assert_equal 'LONGRGB', LONGRGB.to_s
    assert_equal 'ULONGRGB', ULONGRGB.to_s
    assert_equal 'SFLOATRGB', SFLOATRGB.to_s
    assert_equal 'DFLOATRGB', DFLOATRGB.to_s
  end

  def test_rgb_default
    assert_equal RGB( 0, 0, 0 ), INTRGB.new[]
  end

  def test_rgb_indgen
    assert_equal 0, INTRGB.indgen
    assert_equal RGB( 1, 2, 3 ), INTRGB.indgen( RGB( 1, 2, 3 ) )
    assert_equal RGB( 1, 2, 3 ), INTRGB.indgen( RGB( 1, 2, 3 ), 1 )
  end

  def test_rgb_typecode
    assert_equal BYTERGB, BYTERGB.typecode
  end

  def test_rgb_dimension
    assert_equal 0, SFLOATRGB.dimension
  end

  def test_rgb_shape
    assert_equal [], SFLOATRGB.shape
  end

  def test_rgb_size
    assert_equal 1, SINTRGB.size
  end

  def test_inspect
    assert_equal 'RGB(1,2,3)', RGB( 1, 2, 3 ).inspect
  end

  def test_marshal
    assert_equal RGB( 1, 2, 3 ), Marshal.load( Marshal.dump( RGB( 1, 2, 3 ) ) )
  end

  def test_typecode
    assert_equal INTRGB, INTRGB.new.typecode
  end

  def test_dimension
    assert_equal 0, INTRGB.new.dimension
  end

  def test_shape
    assert_equal [], INTRGB.new.shape
  end
  
  def test_size
    assert_equal 1, UBYTERGB.new.size
  end

  def test_at_assign
    c = INTRGB RGB( 1, 2, 3 )
    assert_equal RGB( 1, 2, 3 ), c[]
    assert_equal RGB( 4, 5, 6 ), c[] = RGB( 4, 5, 6 )
    assert_equal RGB( 4, 5, 6 ), c[]
  end

  def test_equal
    assert_not_equal RGB( 1, 2, 3 ), RGB( 2, 2, 3 )
    assert_not_equal RGB( 1, 2, 3 ), RGB( 1, 3, 3 )
    assert_not_equal RGB( 1, 2, 3 ), RGB( 1, 2, 2 )
    assert_equal RGB( 1, 2, 3 ), RGB( 1, 2, 3 )
    assert_equal RGB( 3, 3, 3 ), 3
    assert_not_equal RGB( 3, 3, 3 ), 4
  end

  def test_r_g_b
    assert_equal 1, RGB( 1, 2, 3 ).r
    assert_equal 2, RGB( 1, 2, 3 ).g
    assert_equal 3, RGB( 1, 2, 3 ).b
  end

  def test_inject
    assert_equal RGB( 1, 2, 3 ), INTRGB( RGB( 1, 2, 3 ) ).
                 inject { |a,b| a + b }[]
    assert_equal RGB( 3, 5, 7 ), INTRGB( RGB( 1, 2, 3 ) ).
                 inject( RGB( 2, 3, 4 ) ) { |a,b| a + b }[]
  end

  def test_decompose
    assert_equal [ 1, 2, 3 ], RGB( 1, 2, 3 ).decompose.to_a
  end

  def test_not
    assert !RGB( 0, 0, 0 ).not
    assert !RGB( 1, 2, 3 ).not
  end

  def test_sum
    assert_equal RGB( 1, 2, 3 ), sum { || RGB 1, 2, 3 }
  end

  def test_zero
    assert RGB( 0, 0, 0 ).zero?
    assert !RGB( 1, 0, 0 ).zero?
    assert !RGB( 0, 1, 0 ).zero?
    assert !RGB( 0, 0, 1 ).zero?
  end

  def test_nonzero
    assert !RGB( 0, 0, 0 ).nonzero?
    assert RGB( 1, 0, 0 ).nonzero?
    assert RGB( 0, 1, 0 ).nonzero?
    assert RGB( 0, 0, 1 ).nonzero?
  end

  def test_bitwise_not
    assert_equal RGB( -2, -3, -4 ), ~RGB( 1, 2, 3 )
  end

  def test_bitwise_and
    assert_equal RGB( 1, 2, 1 ), RGB( 1, 2, 3 ) & RGB( 3, 2, 1 )
    assert_equal RGB( 2, 2, 0 ), 2 & RGB( 3, 2, 1 )
    assert_equal RGB( 0, 2, 2 ), RGB( 1, 2, 3 ) & 2
  end

  def test_bitwise_or
    assert_equal RGB( 3, 2, 3 ), RGB( 1, 2, 3 ) | RGB( 3, 2, 1 )
  end

  def test_shl
    assert_equal RGB( 2, 4, 6 ), RGB( 1, 2, 3 ) << 1
  end

  def test_shr
    assert_equal RGB( 1, 2, 3 ), RGB( 2, 4, 6 ) >> 1
  end

  def test_negate
    assert_equal RGB( -1, -2, -3 ), -RGB( 1, 2, 3 )
  end

  def test_plus
    assert_equal RGB( 5, 7, 9 ), RGB( 1, 2, 3 ) + RGB( 4, 5, 6 )
    assert_equal RGB( 2, 3, 4 ), RGB( 1, 2, 3 ) + 1
    assert_equal RGB( 2, 3, 4 ), 1 + RGB( 1, 2, 3 )
  end

  def test_major
    assert_equal RGB( 4, 3, 3 ), RGB( 1, 2, 3 ).major( RGB( 4, 3, 2 ) )
  end

  def test_minor
    assert_equal RGB( 1, 2, 2 ), RGB( 1, 2, 3 ).minor( RGB( 4, 3, 2 ) )
  end

end
