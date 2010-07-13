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

  def sum( *args, &action )
    Hornetseye::sum *args, &action
  end

  def setup
    @s = S[ -1, 2, 3, 5, 7 ]
    @m = M[ [ -1, 2, 3 ], [ 4, 5, 6 ] ]
    @w = 2 * 10 ** 6
    @h = 10 ** 6
  end

  def teardown
  end

  def test_const
    assert_equal 0, lazy { 0 }
    assert_equal [ 0, 0, 0 ], lazy( 3 ) { 0 }.to_a
    assert_equal [ 0, 0, 0 ], lazy( 3 ) { |i| 0 }.to_a
  end

  def test_index
    assert_equal [ 0, 1, 2 ], lazy( 3 ) { |i| i }.to_a
    assert_equal [ [ 0, 1, 2 ], [ 0, 1, 2 ] ], lazy( 3, 2 ) { |i,j| i }.to_a
    assert_equal [ [ 0, 0, 0 ], [ 1, 1, 1 ] ], lazy( 3, 2 ) { |i,j| j }.to_a
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
    assert_equal 3, lazy { lazy( @h ) { |i| i }[ 3 ] }
    assert_equal 5, lazy { lazy( @w, @h ) { |i,j| 2 * i + j }[ 2, 1 ] }
  end

  def test_index_slice
    assert_equal [ 3, 4, 5 ], lazy { lazy( @h ) { |i| i }[ 3 .. 5 ] }.to_a
    assert_equal [ [ 5, 7, 9 ], [ 6, 8, 10 ] ],
      lazy { lazy( @w, @h ) { |i,j| 2 * i + j }[ 2 .. 4, 1 .. 2 ] }.to_a
  end

  def test_index_inject
    assert_equal 10, lazy( 5 ) { |i| i }.inject { |a,b| a + b }
    assert_equal [ 0, 3, 6, 9 ], sum { |k| lazy( 4, 3 ) { |i,j| i }[ k ] }.to_a
    assert_equal [ 3, 3, 3, 3 ], sum { |k| lazy( 4, 3 ) { |i,j| j }[ k ] }.to_a
  end

  def test_indgen_diagonal
    assert_equal [ 15, 18, 17 ],
                 M( I, 4, 3 ).indgen.diagonal { |a,b| a + b }.to_a
  end

end

