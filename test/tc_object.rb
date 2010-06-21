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

class TC_Object < Test::Unit::TestCase

  O = Hornetseye::OBJECT

  def setup
  end

  def teardown
  end

  def test_object_inspect
    assert_equal 'OBJECT', O.inspect
  end

  def test_object_to_s
    assert_equal 'OBJECT', O.to_s
  end

  def test_object_default
    assert_nil O.new[]
  end

  def test_object_typecode
    assert_equal O, O.typecode
  end

  def test_object_dimension
    assert_equal 0, O.dimension
  end

  def test_object_shape
    assert_equal [], O.shape
  end

  def test_object_size
    assert_equal 1, O.size
  end

  def test_inspect
    assert_equal 'OBJECT(42)', O.new( 42 ).inspect
  end

  def test_marshal
    assert_equal O.new( 42 ), Marshal.load( Marshal.dump( O.new( 42 ) ) )
  end

  def test_typecode
    assert_equal O, O.new.typecode
  end

  def test_dimension
    assert_equal 0, O.new.dimension
  end

  def test_shape
    assert_equal [], O.new.shape
  end

  def test_size
    assert_equal 1, O.new.size
  end

  def test_at_assign
    o = O.new 3
    assert_equal 3, o[]
    assert_equal 42, o[] = 42
    assert_equal 42, o[]
  end

  def test_equal
    assert_not_equal O.new( 3 ), O.new( 4 )
    assert_equal O.new( 3 ), O.new( 3 )
  end

  def test_inject
    assert_equal 2, O.new( 2 ).inject { |a,b| a + b }[]
    assert_equal 3, O.new( 2 ).inject( 1 ) { |a,b| a + b }[]
  end

  def test_zero
    assert O.new( 0 ).zero?[]
    assert !O.new( 3 ).zero?[]
  end

  def test_negate
    assert_equal O.new( -5 ), -O.new( 5 )
  end

  def test_plus
    assert_equal O.new( 3 + 5 ), O.new( 3 ) + O.new( 5 )
  end

end
