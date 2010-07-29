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
  C = Hornetseye::INTRGB

  def S( *args )
    Hornetseye::Sequence *args
  end

  def C( *args )
    Hornetseye::RGB *args
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
    assert_equal [ nil, nil, nil ], S( O, 3 ).default.to_a
    assert_equal [ 0, 0, 0 ], S( I, 3 ).default.to_a
  end

  def test_sequence_indgen
    assert_equal [ 0, 1, 2 ], S( I, 3 ).indgen.to_a
    assert_equal [ 1, 2, 3 ], S( I, 3 ).indgen( 1 ).to_a
    assert_equal [ 0, 2, 4 ], S( I, 3 ).indgen( 0, 2 ).to_a
    assert_equal [ 1, 3, 5 ], S( I, 3 ).indgen( 1, 2 ).to_a
  end

  def test_sequence_at
    assert_equal "Sequence(INT,3):\n[ 1, 2, 3 ]",
                 S( I, 3 )[ 1, 2, 3 ].inspect
    assert_equal "Sequence(OBJECT,3):\n[ 1, 2, 3 ]",
                 S( O, 3 )[ 1, 2, 3 ].inspect
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

  def test_sequence_size
    assert_equal 3, S( O, 3 ).size
  end

  def test_inspect
    assert_equal "Sequence(OBJECT,0):\n[]", S[].inspect
    assert_equal "Sequence(OBJECT,3):\n[ :a, 2, 3 ]", S[ :a, 2, 3 ].inspect
  end

  def test_typecode
    assert_equal O, S.new( O, 3 ).typecode
    assert_equal I, S.new( I, 3 ).typecode
  end

  def test_dimension
    assert_equal 1, S[ 1, 2, 3 ].dimension
  end

  def test_shape
    assert_equal [ 3 ], S[ 1, 2, 3 ].shape
  end

  def test_size
    assert_equal 3, S[ 1, 2, 3 ].size
  end

  def test_at_assign
    [ S( O, 3 ), S( I, 3 ) ].each do |t|
      s = t.new
      for i in 0 ... 3
        assert_equal i + 1, s[ i ] = i + 1
      end
      for i in 0 ... 3
        assert_equal i + 1, s[ i ]
      end
    end
  end

  def test_slice
    [ S( O, 4 ), S( I, 4 ) ].each do |t|
      s = t.indgen( 1 )[]
      assert_equal [ 2, 3 ], s[ 1 .. 2 ].to_a
      assert_equal [ 2, 3 ], s[ 1 ... 3 ].to_a
      s[ 1 .. 2 ] = 0
      assert_equal [ 1, 0, 0, 4 ], s.to_a
      s[ 1 ... 3 ] = 5
      assert_equal [ 1, 5, 5, 4 ], s.to_a
      s[ 1 .. 2 ] = S[ 6, 7 ]
      assert_equal [ 1, 6, 7, 4 ], s.to_a
      s[ 1 ... 3 ] = S[ 8, 9 ]
      assert_equal [ 1, 8, 9, 4 ], s.to_a
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
    assert_equal 'abc', S[ 'a', 'b', 'c' ].inject { |a,b| a + b }
    assert_equal 'abcd', S[ 'b', 'c', 'd' ].inject( 'a' ) { |a,b| a + b }
  end

  def test_sum
    [ S( O, 3 ), S( I, 3 ) ].each do |t|
      assert_equal 6, sum { |i| t[ 1, 2, 3 ][ i ] }
      assert_equal [ 1, 2, 3 ], sum { || t[ 1, 2, 3 ] }.to_a
    end
  end

  def test_min
    [ S( O, 3 ), S( I, 3 ) ].each do |t|
      assert_equal 2, t[ 4, 2, 3 ].min
    end
  end

  def test_max
    [ S( O, 3 ), S( I, 3 ) ].each do |t|
      assert_equal 4, t[ 4, 2, 3 ].max
    end
  end

  def test_convolve
    [ O, I ].each do |t|
      assert_equal S( t, 5 )[ 2, 3, 0, 0, 0 ],
                   S( t, 5 )[ 1, 0, 0, 0, 0 ].convolve( S( t, 3 )[ 1, 2, 3 ] )
      assert_equal S( t, 5 )[ 1, 2, 3, 0, 0 ],
                   S( t, 5 )[ 0, 1, 0, 0, 0 ].convolve( S( t, 3 )[ 1, 2, 3 ] )
      assert_equal S( t, 5 )[ 0, 1, 2, 3, 0 ],
                   S( t, 5 )[ 0, 0, 1, 0, 0 ].convolve( S( t, 3 )[ 1, 2, 3 ] )
      assert_equal S( t, 5 )[ 0, 0, 1, 2, 3 ],
                   S( t, 5 )[ 0, 0, 0, 1, 0 ].convolve( S( t, 3 )[ 1, 2, 3 ] )
      assert_equal S( t, 5 )[ 0, 0, 0, 1, 2 ],
                   S( t, 5 )[ 0, 0, 0, 0, 1 ].convolve( S( t, 3 )[ 1, 2, 3 ] )
      assert_equal S( t, 4 )[ 1, 2, 3, 0 ],
                   S( t, 4 )[ 0, 1, 0, 0 ].convolve( S( t, 3 )[ 1, 2, 3 ] )
    end
  end

  def test_zero
    [ S( O, 3 ), S( I, 3 ) ].each do |t|
      assert_equal S[ false, true, false ], t[ -1, 0, 1 ].zero?
    end
  end

  def test_nonzero
    [ S( O, 3 ), S( I, 3 ) ].each do |t|
      assert_equal S[ true, false, true ], t[ -1, 0, 1 ].nonzero?
    end
  end

  def test_not
    assert_equal [ true, false ], S( O, 2 )[ false, true ].not.to_a
    assert_equal [ true, false ], S( B, 2 )[ false, true ].not.to_a
    assert_equal [ true, false, false ], S[ 0, 1, 2 ].not.to_a
  end

  def test_and
    assert_equal [ false, false ], S[ false, true ].and( false ).to_a
    assert_equal [ false, false ], false.and( S[ false, true ] ).to_a
    assert_equal [ false, true ], S[ false, true ].and( true ).to_a
    assert_equal [ false, true ], true.and( S[ false, true ] ).to_a
    assert_equal [ false, false, false, true ], S[ false, true, false, true ].
                 and( S[ false, false, true, true ] ).to_a
  end

  def test_or
    assert_equal [ false, true ], S[ false, true ].or( false ).to_a
    assert_equal [ false, true ], false.or( S[ false, true ] ).to_a
    assert_equal [ true, true ], S[ false, true ].or( true ).to_a
    assert_equal [ true, true ], true.or( S[ false, true ] ).to_a
    assert_equal [ false, true, true, true ], S[ false, true, false, true ].
                 or( S[ false, false, true, true ] ).to_a
  end

  def test_bitwise_not
    [ S( O, 4 ), S( I, 4 ) ].each do |t|
      assert_equal [ 0, -1, -2, -3 ], ( ~t[ -1, 0, 1, 2 ] ).to_a
    end
  end

  def test_bitwise_and
    [ S( O, 3 ), S( I, 3 ) ].each do |t|
      assert_equal [ 0, 1, 0 ], ( t[ 0, 1, 2 ] & 1 ).to_a
      assert_equal [ 0, 1, 0 ], ( 1 & t[ 0, 1, 2 ] ).to_a
      assert_equal [ 0, 1, 2 ], ( t[ 0, 1, 3 ] & t[ 4, 3, 2 ] ).to_a
    end
  end

  def test_bitwise_or
    assert_equal [ 1, 1, 3 ], ( S[ 0, 1, 2 ] | 1 ).to_a
    assert_equal [ 1, 1, 3 ], ( 1 | S[ 0, 1, 2 ] ).to_a
    assert_equal [ 4, 3, 3, 3 ], ( S[ 0, 1, 2, 3 ] | S[ 4, 3, 1, 2 ] ).to_a
  end

  def test_bitwise_xor
    assert_equal [ 1, 0, 3 ], ( S[ 0, 1, 2 ] ^ 1 ).to_a
    assert_equal [ 1, 0, 3 ], ( 1 ^ S[ 0, 1, 2 ] ).to_a
    assert_equal [ 4, 2, 3, 1 ], ( S[ 0, 1, 2, 3 ] ^ S[ 4, 3, 1, 2 ] ).to_a
  end

  def test_shl
    assert_equal [ 2, 4, 6 ], ( S[ 1, 2, 3 ] << 1 ).to_a
    assert_equal [ 6, 12, 24 ], ( 3 << S[ 1, 2, 3 ] ).to_a
    assert_equal [ 8, 8, 6 ], ( S[ 1, 2, 3 ] << S[ 3, 2, 1 ] ).to_a
  end

  def test_shr
    assert_equal [ 1, 2, 3 ], ( S[ 2, 4, 6 ] >> 1 ).to_a
    assert_equal [ 12, 6, 3 ], ( 24 >> S[ 1, 2, 3 ] ).to_a
    assert_equal [ 2, 1, 3 ], ( S[ 16, 4, 6 ] >> S[ 3, 2, 1 ] ).to_a
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
    assert_equal S[ C( 2, 3, 4 ), C( 5, 6, 7 ) ], S[ C( 1, 2, 3 ), C( 4, 5, 6 ) ] + 1
    assert_equal S[ C( 2, 3, 4 ), C( 5, 6, 7 ) ], 1 + S[ C( 1, 2, 3 ), C( 4, 5, 6 ) ]
    assert_equal S[ C( 2, 3, 4 ), C( 3, 4, 5 ) ], S[ 1, 2 ] + C( 1, 2, 3 )
  end

  def test_major
    assert_equal [ 2, 2, 3 ], S[ 1, 2, 3 ].major( 2 ).to_a
    assert_equal [ 2, 2, 3 ], 2.major( S[ 1, 2, 3 ] ).to_a
    assert_equal [ 3, 2, 3 ], S[ 1, 2, 3 ].major( S[ 3, 2, 1 ] ).to_a
  end

  def test_minor
    assert_equal [ 1, 2, 2 ], S[ 1, 2, 3 ].minor( 2 ).to_a
    assert_equal [ 1, 2, 2 ], 2.minor( S[ 1, 2, 3 ] ).to_a
    assert_equal [ 1, 2, 1 ], S[ 1, 2, 3 ].minor( S[ 3, 2, 1 ] ).to_a
  end

  def test_default
    assert_equal [ nil, nil, nil ], S( O, 3 ).default.to_a
    assert_equal [ 0, 0, 0 ], S( I, 3 ).default.to_a
  end

  def test_indgen
    [ S( O, 3 ), S( I, 3 ) ].each do |t|
      assert_equal [ 0, 1, 2 ], t.indgen.to_a
      assert_equal [ 1, 2, 3 ], ( t.indgen + 1 ).to_a
      assert_equal [ 1, 2, 3 ], t.indgen( 1 ).to_a
      assert_equal [ 1, 3, 5 ], ( 2 * t.indgen + 1 ).to_a
      assert_equal [ 1, 3, 5 ], t.indgen( 1, 2 ).to_a
    end
  end

end
