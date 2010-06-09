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

class TC_Sequence < Test::Unit::TestCase

  O = Hornetseye::OBJECT
  B = Hornetseye::BOOL
  I = Hornetseye::INT
  S = Hornetseye::Sequence

  def S( *args )
    Hornetseye::Sequence *args
  end
  
  def sum( *args, &action )
    Hornetseye::sum *args, &action
  end

  def setup
  end

  def teardown
  end

  def test_sequence_inspect
    assert_equal 'Sequence(OBJECT,3)', S( O, 3 ).inspect
  end
  
  def test_sequence_to_s
    assert_equal 'Sequence(OBJECT,3)', S( O, 3 ).to_s
  end

  def test_sequence_default
    assert_equal [ O.default ] * 3, S( O, 3 ).default.to_a
  end

  def test_sequence_indgen
    assert_equal [ 0, 1, 2 ], S( O, 3 ).indgen.to_a
    assert_equal [ 1, 2, 3 ], S( O, 3 ).indgen( 1 ).to_a
    assert_equal [ 0, 2, 4 ], S( O, 3 ).indgen( 0, 2 ).to_a
    assert_equal [ 1, 3, 5 ], S( O, 3 ).indgen( 1, 2 ).to_a
  end

  def test_sequence_at
    assert_equal [ 1, 2, 3 ], S[ 1, 2, 3 ].to_a
    assert_equal O, S[ :a ].typecode
    assert_equal B, S[ false, true ].typecode
    assert_equal I, S[ -2 ** 31, 2 ** 31 - 1 ].typecode
  end

  def test_sequence_typecode
    assert_equal O, S( O, 3 ).typecode
  end

  def test_sequence_dimension
    assert_equal 1, S( O, 3 ).dimension
  end

  def test_sequence_shape
    assert_equal [ 3 ], S( O, 3 ).shape
  end

  def test_inspect
    assert_equal "Sequence(OBJECT,3):\n[ :a, 2, 3 ]", S[ :a, 2, 3 ].inspect
  end

  def test_typecode
    assert_equal O, S.new( O, 3 ).typecode
  end

  def test_dimension
    assert_equal 1, S[ 1, 2, 3 ].dimension
  end

  def test_shape
    assert_equal [ 3 ], S[ 1, 2, 3 ].shape
  end

  def test_at_assign
    s = S.new O, 3
    for i in 0 ... 3
      assert_equal i + 1, s[ i ] = i + 1
    end
    for i in 0 ... 3
      assert_equal i + 1, s[ i ]
    end
  end

  def test_equal
    assert_equal S[ 2, 3, 5 ], S[ 2, 3, 5 ]
    assert_not_equal S[ 2, 3, 5 ], S[ 2, 3, 7 ]
    #assert_not_equal S[ 2, 3, 5 ], S[ 2, 3 ] # !!!
    #assert_not_equal S[ 2, 3, 5 ], S[ 2, 3, 5, 7 ]
    assert_not_equal S[ 2, 2, 2 ], 2
  end

  def test_inject
    assert_equal 6, S[ 1, 2, 3 ].inject { |a,b| a + b }
    assert_equal 10, S[ 1, 2, 3 ].inject( 4 ) { |a,b| a + b }
  end

  def test_sum
    assert_equal 6, sum { |i| S[ 1, 2, 3 ][ i ] }
    assert_equal [ 1, 2, 3 ], sum { || S[ 1, 2, 3 ] }.to_a
  end

  def dont_test_convolve
    assert_equal S[ 2, 3, 0, 0, 0 ],
                 S[ 1, 0, 0, 0, 0 ].convolve( S[ 1, 2, 3 ] )
    assert_equal S[ 1, 2, 3, 0, 0 ],
                 S[ 0, 1, 0, 0, 0 ].convolve( S[ 1, 2, 3 ] )
    assert_equal S[ 0, 1, 2, 3, 0 ],
                 S[ 0, 0, 1, 0, 0 ].convolve( S[ 1, 2, 3 ] )
    assert_equal S[ 0, 0, 1, 2, 3 ],
                 S[ 0, 0, 0, 1, 0 ].convolve( S[ 1, 2, 3 ] )
    assert_equal S[ 0, 0, 0, 1, 2 ],
                 S[ 0, 0, 0, 0, 1 ].convolve( S[ 1, 2, 3 ] )
    assert_equal S[ 1, 2, 3, 0 ],
                 S[ 0, 1, 0, 0 ].convolve( S[ 1, 2, 3 ] )
  end

  def test_zero
    assert_equal S[ false, true, false ], S[ -1, 0, 1 ].zero?
  end

  def test_nonzero
    assert_equal S[ true, false, true ], S[ -1, 0, 1 ].nonzero?
  end

  def test_not
    assert_equal [ true, false ], S[ false, true ].not.to_a
    assert_equal [ true, false, false ], S[ 0, 1, 2 ].not.to_a
  end

  def test_and
    assert_equal [ false, false ], S[ false, true ].and( false ).to_a
    assert_equal [ false, true ], S[ false, true ].and( true ).to_a
    assert_equal [ false, false, false, true ], S[ false, true, false, true ].
                 and( S[ false, false, true, true ] ).to_a
  end

  def test_or
    assert_equal [ false, true ], S[ false, true ].or( false ).to_a
    assert_equal [ true, true ], S[ false, true ].or( true ).to_a
    assert_equal [ false, true, true, true ], S[ false, true, false, true ].
                 or( S[ false, false, true, true ] ).to_a
  end

  def test_bitwise_not
    assert_equal [ 255, 254, 253 ], ( ~S[ 0, 1, 2 ] ).to_a
    assert_equal [ 0, -1, -2, -3 ], ( ~S[ -1, 0, 1, 2 ] ).to_a
  end

  def test_bitwise_and
    assert_equal [ 0, 1, 0 ], S[ 0, 1, 2 ].&( 1 ).to_a
    assert_equal [ 0, 1, 0, 2 ], S[ 0, 1, 2, 3 ].&( S[ 4, 3, 1, 2 ] ).to_a
  end

  def test_bitwise_or
    assert_equal [ 1, 1, 3 ], S[ 0, 1, 2 ].|( 1 ).to_a
    assert_equal [ 4, 3, 3, 3 ], S[ 0, 1, 2, 3 ].|( S[ 4, 3, 1, 2 ] ).to_a
  end

  def test_negate
    assert_equal S[ -1, 2, -3 ], -S[ 1, -2, 3 ]
  end

  def test_plus
    assert_equal S[ 'ax', 'bx' ], S[ 'a', 'b' ] + 'x'
    assert_equal S[ 'xa', 'xb' ], O.new( 'x' ) + S[ 'a', 'b' ]
    assert_equal S[ 'ac', 'bd' ], S[ 'a', 'b' ] + S[ 'c', 'd' ]
    assert_equal S[ 2, 3, 5 ], S[ 1, 2, 4 ] + 1
    assert_equal S[ 2, 3, 5 ], 1 + S[ 1, 2, 4 ]
    assert_equal S[ 2, 3, 5 ], S[ 1, 2, 3 ] + S[ 1, 1, 2 ]
  end

end
