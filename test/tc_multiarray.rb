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

class TC_MultiArray < Test::Unit::TestCase

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

  def sum( *args, &action )
    Hornetseye::sum *args, &action
  end

  def eager( *args, &action )
    Hornetseye::eager *args, &action
  end

  def setup
  end

  def teardown
  end

  def test_multiarray_inspect
    assert_equal 'MultiArray(OBJECT,3,2)', M( O, 3, 2 ).inspect
  end

  def test_multiarray_to_s
    assert_equal 'MultiArray(OBJECT,3,2)', M( O, 3, 2 ).to_s
  end

  def test_multiarray_default
    assert_equal [ [ O.default ] * 3 ] * 2, M( O, 3, 2 ).default.to_a
  end

  def test_multiarray_at
    assert_equal [ [ 1, 2, 3 ], [ 4, 5, 6 ] ],
                 M[ [ 1, 2, 3 ], [ 4, 5, 6 ] ].to_a
    assert_equal O, M[ [ :a ] ].typecode
    assert_equal B, M[ [ false ], [ true ] ].typecode
    assert_equal I, M[ [ -2 ** 31, 2 ** 31 - 1 ] ].typecode
  end

  def test_multiarray_indgen
    assert_equal [ [ 0, 1, 2 ], [ 3, 4, 5 ] ],
                 M( I, 3, 2 ).indgen.to_a
    assert_equal [ [ 1, 2, 3 ], [ 4, 5, 6 ] ],
                 M( I, 3, 2 ).indgen( 1 ).to_a
    assert_equal [ [ 0, 2, 4 ], [ 6, 8, 10 ] ],
                 M( I, 3, 2 ).indgen( 0, 2 ).to_a
    assert_equal [ [ 1, 3, 5 ], [ 7, 9, 11 ] ],
                 M( I, 3, 2 ).indgen( 1, 2 ).to_a
  end

  def test_multiarray_typecode
    assert_equal O, M( O, 3, 2 ).typecode
  end

  def test_multiarray_dimension
    assert_equal 2, M( O, 3, 2 ).dimension
  end

  def test_multiarray_shape
    assert_equal [ 3, 2 ], M( O, 3, 2 ).shape
  end

  def test_multiarray_size
    assert_equal 6, M( O, 3, 2 ).size
  end

  def test_inspect
    assert_equal "MultiArray(OBJECT,3,2):\n[ [ :a, 2, 3 ],\n  [ 4, 5, 6 ] ]",
                 M[ [ :a, 2, 3 ], [ 4, 5, 6 ] ].inspect
  end

  def test_typecode
    assert_equal O, M( O, 3, 2 ).new.typecode
  end

  def test_dimension
    assert_equal 2, M( O, 3, 2 ).new.dimension
  end

  def test_shape
    assert_equal [ 3, 2 ], M( O, 3, 2 ).new.shape
  end

  def test_size
    assert_equal 6, M( O, 3, 2 ).new.size
  end

  def test_at_assign
    m = M.new O, 3, 2
    for j in 0 ... 2
      for i in 0 ... 3
        assert_equal j * 3 + i + 1, m[ j ][ i ] = j * 3 + i + 1
        assert_equal j * 3 + i + 1, m[ i, j ] = j * 3 + i + 1
      end
    end
    for j in 0 ... 2
      for i in 0 ... 3
        assert_equal j * 3 + i + 1, m[ j ][ i ]
        assert_equal j * 3 + i + 1, m[ i, j ]
      end
    end
  end

  def test_equal
    assert_equal M[ [ 1, 2, 3 ], [ 4, 5, 6 ] ], M[ [ 1, 2, 3 ], [ 4, 5, 6 ] ]
    assert_not_equal M[ [ 1, 2, 3 ], [ 4, 5, 6 ] ],
                     M[ [ 1, 2, 3 ], [ 4, 6, 5 ] ]
    # !!!
    assert_not_equal M[ [ 1, 1 ], [ 1, 1 ] ], 1
    assert_not_equal M[ [ 1, 1 ], [ 1, 1 ] ], S[ 1, 1 ]
  end

  def test_inject
    assert_equal 21, M[ [ 1, 2, 3 ], [ 4, 5, 6 ] ].inject { |a,b| a + b }
    assert_equal 28, M[ [ 1, 2, 3 ], [ 4, 5, 6 ] ].inject( 7 ) { |a,b| a + b }
  end

  def test_sum
    m = M[ [ 1, 2, 3 ], [ 4, 5, 6 ] ]
    assert_equal 21, sum { |i,j| m[ i, j ] }
    assert_equal [ 5, 7, 9 ], sum { |i| m[ i ] }.to_a
    assert_equal [ 6, 15 ], eager { |j| sum { |i| m[ i, j ] } }.to_a
    assert_equal [ [ 1, 2, 3 ] , [ 4, 5, 6 ] ], sum { || m }.to_a
  end

  def dont_test_convolve
    f = M[ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ]
    assert_equal M[ [ 5, 6, 0 ], [ 8, 9, 0 ], [ 0, 0, 0 ] ],
                 M[ [ 1, 0, 0 ], [ 0, 0, 0 ], [ 0, 0, 0 ] ].convolve( f )
    assert_equal M[ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ],
                 M[ [ 0, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 0 ] ].convolve( f )
    assert_equal M[ [ 0, 0, 0 ], [ 1, 2, 3 ], [ 4, 5, 6 ] ],
                 M[ [ 0, 0, 0 ], [ 0, 0, 0 ], [ 0, 1, 0 ] ].convolve( f )
  end

  def test_zero
    assert_equal M[ [ false, true ], [ true, false ] ],
                 M[ [ -1, 0 ], [ 0, 1 ] ].zero?
  end

  def test_nonzero
    assert_equal M[ [ true, false ], [ false, true ] ],
                 M[ [ -1, 0 ], [ 0, 1 ] ].nonzero?
  end

  def test_not
    assert_equal [ [ true, false ], [ false, true ] ],
                 M[ [ false, true ], [ true, false ] ].not.to_a
    assert_equal [ [ true, false ], [ false, true ] ],
                 M[ [ 0, 1 ], [ 2, 0 ] ].not.to_a
  end

  def test_and
    assert_equal [ [ false, false ] ], M[ [ false, true ] ].and( false ).to_a
    assert_equal [ [ false, false ] ], false.and( M[ [ false, true ] ] ).to_a
    assert_equal [ [ false, true ] ], M[ [ false, true ] ].and( true ).to_a
    assert_equal [ [ false, true ] ], true.and( M[ [ false, true ] ] ).to_a
    assert_equal [ [ false, false ], [ false, true ] ],
                 M[ [ false, true ], [ false, true ] ].
                 and( M[ [ false, false ], [ true, true ] ] ).to_a
    assert_equal [ [ false, false ], [ true, false ] ],
                 M[ [ false, true ], [ true, false ] ].
                 and( S[ false, true ] ).to_a
  end

  def test_or
    assert_equal [ [ false, true ] ], M[ [ false, true ] ].or( false ).to_a
    assert_equal [ [ false, true ] ], false.or( M[ [ false, true ] ] ).to_a
    assert_equal [ [ true, true ] ], M[ [ false, true ] ].or( true ).to_a
    assert_equal [ [ true, true ] ], true.or( M[ [ false, true ] ] ).to_a
    assert_equal [ [ false, true ], [ true, true ] ],
                 M[ [ false, true ], [ false, true ] ].
                 or( M[ [ false, false ], [ true, true ] ] ).to_a
    assert_equal [ [ false, true ], [ true, true ] ],
                 M[ [ false, true ], [ true, false ] ].
                 or( S[ false, true ] ).to_a
  end

  def test_bitwise_not
    assert_equal [ [ 255, 254 ], [ 253, 252 ] ],
                 ( ~M[ [ 0, 1 ], [ 2, 3 ] ] ).to_a
    assert_equal [ [ 0, -1 ], [ -2, -3 ] ],
                 ( ~M[ [ -1, 0 ], [ 1, 2 ] ] ).to_a
  end

  def test_bitwise_and
    assert_equal [ [ 0, 1 ], [ 0, 1 ] ], ( M[ [ 0, 1 ], [ 2, 3 ] ] & 1 ).to_a
    assert_equal [ [ 0, 1 ], [ 0, 1 ] ], ( 1 & M[ [ 0, 1 ], [ 2, 3 ] ] ).to_a
    assert_equal [ [ 0, 1 ], [ 0, 2 ] ], ( M[ [ 0, 1 ], [ 2, 3 ] ] &
                                           M[ [ 4, 3 ], [ 1, 2 ] ] ).to_a
  end

  def test_bitwise_or
    assert_equal [ [ 1, 1 ], [ 3, 3 ] ], ( M[ [ 0, 1 ], [ 2, 3 ] ] | 1 ).to_a
    assert_equal [ [ 1, 1 ], [ 3, 3 ] ], ( 1 | M[ [ 0, 1 ], [ 2, 3 ] ] ).to_a
    assert_equal [ [ 4, 3 ], [ 3, 3 ] ], ( M[ [ 0, 1 ], [ 2, 3 ] ] |
                                           M[ [ 4, 3 ], [ 1, 2 ] ] ).to_a
  end

  def test_bitwise_xor
    assert_equal [ [ 1, 0 ], [ 3, 2 ] ], ( M[ [ 0, 1 ], [ 2, 3 ] ] ^ 1 ).to_a
    assert_equal [ [ 1, 0 ], [ 3, 2 ] ], ( 1 ^ M[ [ 0, 1 ], [ 2, 3 ] ] ).to_a
    assert_equal [ [ 4, 2 ], [ 3, 1 ] ], ( M[ [ 0, 1 ], [ 2, 3 ] ] ^
                                           M[ [ 4, 3 ], [ 1, 2 ] ] ).to_a
  end

  def test_shl
    assert_equal [ [ 2, 4 ], [ 6, 8 ] ], ( M[ [ 1, 2 ], [ 3, 4 ] ] << 1 ).to_a
    assert_equal [ [ 6, 12 ], [ 24, 48 ] ],
                 ( 3 << M[ [ 1, 2 ], [ 3, 4 ] ] ).to_a
    assert_equal [ [ 8, 8 ], [ 6, 4 ] ],
                 ( M[ [ 1, 2 ], [ 3, 4 ] ] << M[ [ 3, 2 ], [ 1, 0 ] ] ).to_a
  end

  def test_shr
    assert_equal [ [ 1, 2 ], [ 3, 4 ] ], ( M[ [ 2, 4 ], [ 6, 8 ] ] >> 1 ).to_a
    assert_equal [ [ 24, 12 ], [ 6, 3 ] ],
                 ( 48 >> M[ [ 1, 2 ], [ 3, 4 ] ] ).to_a
    assert_equal [ [ 2, 1 ], [ 3, 2 ] ],
                 ( M[ [ 16, 4 ], [ 6, 2 ] ] >> M[ [ 3, 2 ], [ 1, 0 ] ] ).to_a
  end

  def test_negate
    assert_equal M[ [ -1, 2, -3 ], [ 4, -5, 6 ] ],
                 -M[ [ 1, -2, 3 ], [ -4, 5, -6 ] ]
  end

  def test_plus
    assert_equal M[ [ 2, 3, 5 ], [ 3, 5, 7 ] ],
                 M[ [ 1, 2, 4 ], [ 2, 4, 6 ] ] + 1
    assert_equal M[ [ 2, 3, 5 ], [ 3, 5, 7 ] ],
                 1 + M[ [ 1, 2, 4 ], [ 2, 4, 6 ] ]
    assert_equal M[ [ -3, 2, 1 ], [ 8, 6, 4 ] ] +
                 M[ [ 2, 0, 2 ], [ -4, -1, 2 ] ],
                 M[ [ -1, 2, 3 ], [ 4, 5, 6 ] ]
  end

  def test_default
    assert_equal [ [ nil, nil, nil ], [ nil, nil, nil ] ],
                 M( O, 3, 2 ).default.to_a
    assert_equal [ [ 0, 0, 0 ], [ 0, 0, 0 ] ], M( I, 3, 2 ).default.to_a
  end

end
