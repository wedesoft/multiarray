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

class TC_Float < Test::Unit::TestCase

  F = Hornetseye::SFLOAT
  D = Hornetseye::DFLOAT

  def F( *args )
    Hornetseye::SFLOAT *args
  end

  def D( *args )
    Hornetseye::DFLOAT *args
  end

  def sum( *args, &action )
    Hornetseye::sum *args, &action
  end

  def setup
  end

  def teardown
  end

  def test_float_inspect
    assert_equal 'SFLOAT', F.inspect
    assert_equal 'DFLOAT', D.inspect
  end

  def test_float_to_s
    assert_equal 'SFLOAT', F.to_s
    assert_equal 'DFLOAT', D.to_s
  end

  def test_float_default
    assert_equal 0.0, F.new[]
    assert_equal 0.0, D.new[]
  end

  def test_float_indgen
    assert_equal 0, F.indgen
    assert_equal 1, F.indgen( 1 )
    assert_equal 1, F.indgen( 1, 2 )
  end

  def test_float_typecode
    assert_equal F, F.typecode
    assert_equal D, D.typecode
  end

  def test_float_dimension
    assert_equal 0, F.dimension
  end
!
  def test_float_shape
    assert_equal [], F.shape
  end

  def test_float_size
    assert_equal 1, F.size
  end

  def test_inspect
    assert_equal 'DFLOAT(42.0)', D( 42.0 ).inspect
  end

  def test_marshal
    assert_equal D( 42.0 ), Marshal.load( Marshal.dump( D( 42.0 ) ) )
  end

  def test_typecode
    assert_equal D, D.new.typecode
  end

  def test_dimension
    assert_equal 0.0, D.new.dimension
  end

  def test_shape
    assert_equal [], D.new.shape
  end

  def test_size
    assert_equal 1, D.new.size
  end

  def test_at_assign
    d = D 42.0
    assert_equal 42.0, d[]
    assert_equal 3.0, d[] = 3
    assert_equal 3.0, d[]
  end

  def test_equal
    assert_not_equal D( 3.0 ), D( 4.0 )
    assert_equal D( 3.0 ), D( 3.0 )
  end

  def test_r_g_b
    assert_equal D( 3.5 ), D( 3.5 ).r
    assert_equal D( 3.5 ), D( 3.5 ).g
    assert_equal D( 3.5 ), D( 3.5 ).b
  end

  def test_inject
    assert_equal 2.5, D( 2.5 ).inject { |a,b| a + b }[]
    assert_equal 4.0, D( 2.5 ).inject( 1.5 ) { |a,b| a + b }[]
  end

  def test_not
    assert !D( 0.0 ).not[]
    assert !D( 3.0 ).not[]
  end

  def test_sum
    assert_equal 3.5, sum { || 3.5 }
  end

  def test_zero
    assert D( 0.0 ).zero?[]
    assert !D( 3.0 ).zero?[]
  end

  def test_nonzero
    assert !D( 0.0 ).nonzero?[]
    assert D( 3.0 ).nonzero?[]
  end


  def test_negate
    assert_equal D( -3.5 ), -D( 3.5 )
  end

  def test_plus
    assert_equal D( 3.5 + 1.5 ), D( 3.5 ) + D( 1.5 )
  end

  def test_major
    assert_equal D( 4.3 ), D( 3.1 ).major( D( 4.3 ) )
    assert_equal D( 5.1 ), D( 5.1 ).major( D( 3.5 ) )
  end

  def test_minor
    assert_equal D( 3.1 ), D( 3.1 ).minor( D( 4.3 ) )
    assert_equal D( 3.5 ), D( 5.1 ).minor( D( 3.5 ) )
  end

end

