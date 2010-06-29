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

class TC_Lazy < Test::Unit::TestCase

  O = Hornetseye::OBJECT
  B = Hornetseye::BOOL
  I = Hornetseye::INT
  S = Hornetseye::Sequence
  M = Hornetseye::MultiArray

  def S( *args )
    Hornetseye::Sequence *args
  end

  def M( *args )
    Hornetseye::MultiArray *args
  end

  def lazy( *args, &action )
    Hornetseye::lazy *args, &action
  end

  def setup
    @s = S[ -1, 2, 3, 5, 7 ]
    @m = 2 * 10 ** 6
    @n = 10 ** 6
  end

  def teardown
  end

  def test_minus_at
    assert_equal -2, lazy { ( -@s )[ 1 ] } 
  end

  def test_minus_slice
    assert_equal [ -2, -3, -5 ], lazy { ( -@s )[ 1 .. 3 ] }.to_a
  end

  def test_add_at
    assert_equal 4, lazy { ( @s + @s )[ 1 ] }
  end

  def test_add_slice
    assert_equal [ 6, 10, 14 ], lazy { ( @s + @s )[ 2 .. 4 ] }.to_a
  end

  def test_index_at
    assert_equal 3, lazy { lazy( @n ) { |i| i }[ 3 ] }
    assert_equal 5, lazy { lazy( @m, @n ) { |i,j| 2 * i + j }[ 2, 1 ] }
  end

  def test_index_slice
    assert_equal [ 3, 4, 5 ], lazy { lazy( @n ) { |i| i }[ 3 .. 5 ] }.to_a
    assert_equal [ [ 5, 7, 9 ], [ 6, 8, 10 ] ],
      lazy { lazy( @m, @n ) { |i,j| 2 * i + j }[ 2 .. 4, 1 .. 2 ] }.to_a
  end

end

