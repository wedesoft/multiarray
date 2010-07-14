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

class TC_Bool < Test::Unit::TestCase

  B = Hornetseye::BOOL

  def B( *args )
    Hornetseye::BOOL *args
  end

  def setup
  end

  def teardown
  end

  def test_bool_inspect
    assert_equal 'BOOL', B.inspect
  end

  def test_bool_to_s
    assert_equal 'BOOL', B.to_s
  end

  def test_bool_default
    assert_equal false, B.new[]
  end

  def test_bool_typecode
    assert_equal B, B.typecode
  end

  def test_bool_dimension
    assert_equal 0, B.dimension
  end

  def test_bool_shape
    assert_equal [], B.shape
  end

  def test_bool_size
    assert_equal 1, B.size
  end

  def test_inspect
    assert_equal 'BOOL(true)', B( true ).inspect
  end

  def test_marshal
    assert_equal B( true ), Marshal.load( Marshal.dump( B( true ) ) )
  end

  def test_typecode
    assert_equal B, B.new.typecode
  end

  def test_dimension
    assert_equal 0, B.new.dimension
  end

  def test_shape
    assert_equal [], B.new.shape
  end

  def test_size
    assert_equal 1, B.new.size
  end

  def test_at_assign
    b = B false
    assert !b[]
    assert b[] = true
    assert b[]
  end

  def test_equal
    assert_equal B( false ), B( false )
    assert_not_equal B( false ), B( true )
    assert_not_equal B( true ), B( false )
    assert_equal B( true ), B( true )
  end

  def test_inject
    assert B( true ).inject { |a,b| a.and b }[]
    assert !B( false ).inject( true ) { |a,b| a.and b }[]
    assert !B( true ).inject( false ) { |a,b| a.and b }[]
  end

  def test_not
    assert_equal B( true ), B( false ).not
    assert_equal B( false ), B( true ).not
  end

  def test_and
    assert_equal B( false ), B( false ).and( B( false ) )
    assert_equal B( false ), B( false ).and( B( true ) )
    assert_equal B( false ), B( true ).and( B( false ) )
    assert_equal B( true ), B( true ).and( B( true ) )
  end

  def test_or
    assert_equal B( false ), B( false ).or( B( false ) )
    assert_equal B( true ), B( false ).or( B( true ) )
    assert_equal B( true ), B( true ).or( B( false ) )
    assert_equal B( true ), B( true ).or( B( true ) )
  end

end
