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
  C = Hornetseye::INTRGB
  X = Hornetseye::DCOMPLEX
  S = Hornetseye::Sequence
  M = Hornetseye::MultiArray

  def C( *args )
    Hornetseye::RGB *args
  end

  def X( *args )
    Complex *args
  end
  
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
    assert_equal 'MultiArray(OBJECT,3,2)', S( S( O, 3 ), 2 ).inspect
  end

  def test_multiarray_to_s
    assert_equal 'MultiArray(OBJECT,3,2)', M( O, 3, 2 ).to_s
    assert_equal 'MultiArray(OBJECT,3,2)', S( S( O, 3 ), 2 ).to_s
  end

  def test_multiarray_default
    assert_equal [ [ nil ] * 3 ] * 2, M( O, 3, 2 ).default.to_a
    assert_equal [ [ 0 ] * 3 ] * 2, M( I, 3, 2 ).default.to_a
    assert_equal [ [ C( 0, 0, 0 ) ] * 3 ] * 2, M( C, 3, 2 ).default.to_a
  end

  def test_multiarray_at
    assert_equal [ [ 1, 2, 3 ], [ 4, 5, 6 ] ],
                 M[ [ 1, 2, 3 ], [ 4, 5, 6 ] ].to_a
    assert_equal [ [ 1, 2, 3 ], [ 4, 5, 6 ] ],
                 M( O, 3, 2 )[ [ 1, 2, 3 ], [ 4, 5, 6 ] ].to_a
    assert_equal O, M[ [ :a ] ].typecode
    assert_equal B, M[ [ false ], [ true ] ].typecode
    assert_equal I, M[ [ -2 ** 31, 2 ** 31 - 1 ] ].typecode
  end

  def test_multiarray_indgen
    assert_equal M( I, 3, 2 )[ [ 0, 1, 2 ], [ 3, 4, 5 ] ],
                 M( I, 3, 2 ).indgen
    assert_equal M( I, 3, 2 )[ [ 1, 2, 3 ], [ 4, 5, 6 ] ],
                 M( I, 3, 2 ).indgen( 1 )
    assert_equal M( I, 3, 2 )[ [ 0, 2, 4 ], [ 6, 8, 10 ] ],
                 M( I, 3, 2 ).indgen( 0, 2 )
    assert_equal M( I, 3, 2 )[ [ 1, 3, 5 ], [ 7, 9, 11 ] ],
                 M( I, 3, 2 ).indgen( 1, 2 )
    assert_equal M( C, 2, 2 )[ [ C( 1, 2, 3 ), C( 2, 2, 2 ) ],
                               [ C( 3, 2, 1 ), C( 4, 2, 0 ) ] ],
                 M( C, 2, 2 ).indgen( C( 1, 2, 3 ), C( 1, 0, -1 ) )
  end

  def test_multiarray_typecode
    assert_equal O, M( O, 3, 2 ).typecode
    assert_equal I, M( I, 3, 2 ).typecode
    assert_equal C, M( C, 3, 2 ).typecode
  end

  def test_multiarray_dimension
    assert_equal 2, M( O, 3, 2 ).dimension
  end

  def test_multiarray_shape
    assert_equal [ 3, 2 ], M( O, 3, 2 ).shape
  end

  def test_multiarray_size
    assert_equal 6, M( O, 3, 2 ).size
    assert_equal 6, M( I, 3, 2 ).size
    assert_equal 6, M( C, 3, 2 ).size
  end

  def test_inspect
    assert_equal "MultiArray(OBJECT,3,2):\n[ [ :a, 2, 3 ],\n  [ 4, 5, 6 ] ]",
                 M[ [ :a, 2, 3 ], [ 4, 5, 6 ] ].inspect
    assert_equal "MultiArray(UBYTE,4,3,2):\n" +
                 "[ [ [ 0, 1, 2, 3 ],\n" +
                 "    [ 4, 5, 6, 7 ],\n" +
                 "    [ 8, 9, 10, 11 ] ],\n" +
                 "  [ [ 12, 13, 14, 15 ],\n" +
                 "    [ 16, 17, 18, 19 ],\n" +
                 "    [ 20, 21, 22, 23 ] ] ]",
                 M[ [ [ 0, 1, 2, 3 ],
                      [ 4, 5, 6, 7 ],
                      [ 8, 9, 10, 11 ] ],
                    [ [ 12, 13, 14, 15 ],
                      [ 16, 17, 18, 19 ],
                      [ 20, 21, 22, 23 ] ] ].inspect
  end

  def test_dup
    m = M[ [ 1, 2, 3 ], [ 4, 5, 6 ] ]
    v = m.dup
    v[ 2, 1 ] = 0
    assert_equal M[ [ 1, 2, 3 ], [ 4, 5, 6 ] ], m
  end

  def test_typecode
    assert_equal O, M( O, 3, 2 ).new.typecode
    assert_equal I, M( I, 3, 2 ).new.typecode
    assert_equal C, M( C, 3, 2 ).new.typecode
  end

  def test_dimension
    assert_equal 2, M( O, 3, 2 ).new.dimension
    assert_equal 2, M( I, 3, 2 ).new.dimension
    assert_equal 2, M( C, 3, 2 ).new.dimension
  end

  def test_shape
    assert_equal [ 3, 2 ], M( O, 3, 2 ).new.shape
  end

  def test_size
    assert_equal 6, M( O, 3, 2 ).new.size
  end

  def test_import
    assert_equal [ [ 1, 2, 3 ], [ 4, 5, 6 ] ],
                 M.import( I, "\001\000\000\000\002\000\000\000\003\000\000\000" +
                           "\004\000\000\000\005\000\000\000\006\000\000\000",
                           3, 2 ).to_a
  end

  def test_at_assign
    [ M( O, 3, 2 ), M( I, 3, 2 ) ].each do |t|
      m = t.new
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
      assert_raise( RuntimeError ) { m[ -1 ] }
      assert_raise( RuntimeError ) { m[ 2 ] }
      assert_nothing_raised { m[ 0 ] }
      assert_nothing_raised { m[ 1 ] }
      assert_raise( RuntimeError ) { m[ -1 ] = 0 }
      assert_raise( RuntimeError ) { m[ 2 ] = 0 }
      assert_raise( RuntimeError ) { m[ 3, 1 ] }
      assert_raise( RuntimeError ) { m[ 3, 1 ]  = 0 }
      assert_raise( RuntimeError ) { m[ -1, 1 ] }
      assert_raise( RuntimeError ) { m[ -1, 1 ]  = 0 }
      assert_raise( RuntimeError ) { m[ 2, -1 ] }
      assert_raise( RuntimeError ) { m[ 2, -1 ]  = 0 }
      assert_raise( RuntimeError ) { m[ 2, 2 ] }
      assert_raise( RuntimeError ) { m[ 2, 2 ]  = 0 }
      assert_nothing_raised { m[ 0, 0 ] }
      assert_nothing_raised { m[ 2, 1 ] }
      assert_raise( RuntimeError ) { m[ 0 ] = m }
      assert_raise( RuntimeError ) { m[ 0 ] = S[ 0, 1 ] }
      assert_nothing_raised { m[ 0 ] = 0 }
      assert_nothing_raised { m[ 1 ] = 0 }
      assert_nothing_raised { m[ 0 ] = m[ 1 ] }
    end
  end

  def test_slice
    [ M( O, 5, 4 ), M( I, 5, 4 ) ].each do |t|
      m = t.indgen[]
      assert_equal [ [ 5, 10 ], [ 6, 11 ], [ 7, 12 ], [ 8, 13 ], [ 9, 14 ] ],
                   m[ 1 .. 2 ].to_a
      assert_equal [ [ 6, 7, 8 ], [ 11, 12, 13 ] ],
                   m[ 1 .. 2 ][ 1 .. 3 ].to_a
      assert_equal [ [ 6, 7, 8 ], [ 11, 12, 13 ] ],
                   m[ 1 .. 3, 1 .. 2 ].to_a
      m[ 1 .. 2 ] = 0
      assert_equal [ [ 0, 1, 2, 3, 4 ], [ 0, 0, 0, 0, 0 ],
                     [ 0, 0, 0, 0, 0 ], [ 15, 16, 17, 18, 19 ] ], m.to_a
      m[ 1 ... 3 ] = 1
      assert_equal [ [ 0, 1, 2, 3, 4 ], [ 1, 1, 1, 1, 1 ],
                     [ 1, 1, 1, 1, 1 ], [ 15, 16, 17, 18, 19 ] ], m.to_a
      m[ 1 .. 2 ] = S[ 2, 3, 4, 5, 6 ]
      assert_equal [ [ 0, 1, 2, 3, 4 ], [ 2, 3, 4, 5, 6 ],
                     [ 2, 3, 4, 5, 6 ], [ 15, 16, 17, 18, 19 ] ], m.to_a
      m[ 1 ... 3 ] = S[ 3, 4, 5, 6, 7 ]
      assert_equal [ [ 0, 1, 2, 3, 4 ], [ 3, 4, 5, 6, 7 ],
                     [ 3, 4, 5, 6, 7 ], [ 15, 16, 17, 18, 19 ] ], m.to_a
      m[ 1 .. 3, 1 .. 2 ] = 0
      assert_equal [ [ 0, 1, 2, 3, 4 ], [ 3, 0, 0, 0, 7 ],
                     [ 3, 0, 0, 0, 7 ], [ 15, 16, 17, 18, 19 ] ], m.to_a
      m[ 1 ... 4, 1 ... 3 ] = 1
      assert_equal [ [ 0, 1, 2, 3, 4 ], [ 3, 1, 1, 1, 7 ],
                     [ 3, 1, 1, 1, 7 ], [ 15, 16, 17, 18, 19 ] ], m.to_a
      assert_raise( RuntimeError ) { m[ 2 .. 4 ] }
      assert_raise( RuntimeError ) { m[ 2 .. 4 ] = 0 }
      assert_raise( RuntimeError ) { m[ 2 .. 4 ] = m[ 1 .. 3 ] }
      assert_raise( RuntimeError ) { m[ 2 .. 3 ] = m[ 1 .. 3 ] }
      assert_raise( RuntimeError ) { m[ 2 ... 5 ] }
      assert_raise( RuntimeError ) { m[ 2 ... 5 ] = 0 }
      assert_raise( RuntimeError ) { m[ 2 ... 5 ] = m[ 1 ... 4 ] }
      assert_raise( RuntimeError ) { m[ 2 ... 4 ] = m[ 1 ... 4 ] }
      assert_raise( RuntimeError ) { m[ -1 .. 0 ] }
      assert_raise( RuntimeError ) { m[ -1 .. 0 ] = 0 }
      assert_raise( RuntimeError ) { m[ -1 .. 0 ] = m[ 0 .. 1 ] }
      assert_raise( RuntimeError ) { m[ -1 ... 1 ] }
      assert_raise( RuntimeError ) { m[ -1 ... 1 ] = 0 }
      assert_raise( RuntimeError ) { m[ -1 ... 1 ] = m[ 0 ... 2 ] }
      assert_nothing_raised { m[ 0 .. 3 ] }
      assert_nothing_raised { m[ 0 .. 3 ] = 0 }
      assert_nothing_raised { m[ 0 .. 3 ] = m[ 0 .. 3 ] }
      assert_nothing_raised { m[ 0 ... 4 ] }
      assert_nothing_raised { m[ 0 ... 4 ] = 0 }
      assert_nothing_raised { m[ 0 ... 4 ] = m[ 0 ... 4 ] }
      assert_raise( RuntimeError ) { m[ 1 .. 5, 1 ] }
      assert_raise( RuntimeError ) { m[ 1 .. 5, 1 ] = 0 }
      assert_raise( RuntimeError ) { m[ 1 .. 5, 1 ] = m[ 0 .. 4, 1 ] }
      assert_raise( RuntimeError ) { m[ 1 .. 4, 1 ] = m[ 0 .. 4, 1 ] }
      assert_raise( RuntimeError ) { m[ 1 ... 6, 1 ] }
      assert_raise( RuntimeError ) { m[ 1 ... 6, 1 ] = 0 }
      assert_raise( RuntimeError ) { m[ 1 ... 6, 1 ] = m[ 0 ... 5, 1 ] }
      assert_raise( RuntimeError ) { m[ 1 ... 5, 1 ] = m[ 0 ... 5, 1 ] }
      assert_raise( RuntimeError ) { m[ -1 .. 3, 1 ] }
      assert_raise( RuntimeError ) { m[ -1 .. 3, 1 ] = 0 }
      assert_raise( RuntimeError ) { m[ -1 .. 3, 1 ] = m[ 0 .. 4, 1 ] }
      assert_raise( RuntimeError ) { m[ -1 ... 3, 1 ] }
      assert_raise( RuntimeError ) { m[ -1 ... 3, 1 ] = 0 }
      assert_raise( RuntimeError ) { m[ -1 ... 3, 1 ] = m[ 0 ... 4, 1 ] }
      assert_nothing_raised { m[ 0 .. 4, 1 ] }
      assert_nothing_raised { m[ 0 .. 4, 1 ] = 0 }
      assert_nothing_raised { m[ 0 .. 4, 1 ] = m[ 0 .. 4, 0 ] }
      assert_nothing_raised { m[ 0 ... 5, 1 ] }
      assert_nothing_raised { m[ 0 ... 5, 1 ] = 0 }
      assert_nothing_raised { m[ 0 ... 5, 1 ] = m[ 0 ... 5, 0 ] }
      assert_raise( RuntimeError ) { m[ 1, 1 .. 4 ] }
      assert_raise( RuntimeError ) { m[ 1, 1 .. 4 ] = 0 }
      assert_raise( RuntimeError ) { m[ 1, 1 .. 4 ] = m[ 1, 0 .. 3 ] }
      assert_raise( RuntimeError ) { m[ 1, 1 .. 3 ] = m[ 1, 0 .. 3 ] }
      assert_raise( RuntimeError ) { m[ 1, 1 ... 5 ] }
      assert_raise( RuntimeError ) { m[ 1, 1 ... 5 ] = 0 }
      assert_raise( RuntimeError ) { m[ 1, 1 ... 5 ] = m[ 1, 0 ... 4 ] }
      assert_raise( RuntimeError ) { m[ 1, 1 ... 4 ] = m[ 1, 0 ... 4 ] }
      assert_raise( RuntimeError ) { m[ 1, -1 .. 2 ] }
      assert_raise( RuntimeError ) { m[ 1, -1 .. 2 ] = 0 }
      assert_raise( RuntimeError ) { m[ 1, -1 .. 2 ] = m[ 1, 0 .. 3 ] }
      assert_raise( RuntimeError ) { m[ 1, -1 ... 2 ] }
      assert_raise( RuntimeError ) { m[ 1, -1 ... 2 ] = 0 }
      assert_raise( RuntimeError ) { m[ 1, -1 ... 2 ] = m[ 1, 0 ... 3 ] }
      assert_nothing_raised { m[ 1, 0 .. 3 ] }
      assert_nothing_raised { m[ 1, 0 .. 3 ] = 0 }
      assert_nothing_raised { m[ 1, 0 .. 3 ] = m[ 0, 0 .. 3 ] }
      assert_nothing_raised { m[ 1, 0 ... 4 ] }
      assert_nothing_raised { m[ 1, 0 ... 4 ] = 0 }
      assert_nothing_raised { m[ 1, 0 ... 4 ] = m[ 0, 0 ... 4 ] }
    end
  end

  def test_view
    [ M( O, 3, 2 ), M( I, 3, 2 ) ].each do |t|
      m = t[ [ 1, 2, 3 ], [ 4, 5, 6 ] ]
      v = m[ 1, 0 ... 2 ]
      v[] = 0
      assert_equal [ [ 1, 0, 3 ], [ 4, 0, 6 ] ], m.to_a
    end
   end

   def test_transpose
    assert_equal [ [ 1, 4 ], [ 2, 5 ], [ 3, 6 ] ],
                 M[ [ 1, 2, 3 ], [ 4, 5, 6 ] ].transpose( 1, 0 ).to_a
    assert_equal [ [ [ 0, 3 ], [ 1, 4 ], [ 2, 5 ] ] ],
                 M( I, 3, 2, 1 ).indgen.transpose( 1, 0, 2 ).to_a
  end

  def test_roll_unroll
    assert_equal [ [ [ 0 ], [ 1 ], [ 2 ] ], [ [ 3 ], [ 4 ], [ 5 ] ] ],
                 M( I, 3, 2, 1 ).indgen.unroll.to_a
    assert_equal [ [ [ 0, 3 ] ], [ [ 1, 4 ] ], [ [ 2, 5 ] ] ],
                 M( I, 3, 2, 1 ).indgen.roll.to_a
  end

  def test_equal
    assert_equal M[ [ 1, 2, 3 ], [ 4, 5, 6 ] ], M[ [ 1, 2, 3 ], [ 4, 5, 6 ] ]
    assert_not_equal M[ [ 1, 2, 3 ], [ 4, 5, 6 ] ],
                     M[ [ 1, 2, 3 ], [ 4, 6, 5 ] ]
    # !!!
    assert_not_equal M[ [ 1, 1 ], [ 1, 1 ] ], 1
    assert_not_equal M[ [ 1, 1 ], [ 1, 1 ] ], S[ 1, 1 ]
  end

  def test_r_g_b
    assert_equal M[ [ 1, 4 ], [ 5, 6 ] ], M[ [ C( 1, 2, 3 ), 4 ], [ 5, 6 ] ].r
    assert_equal M[ [ 2, 4 ], [ 5, 6 ] ], M[ [ C( 1, 2, 3 ), 4 ], [ 5, 6 ] ].g
    assert_equal M[ [ 3, 4 ], [ 5, 6 ] ], M[ [ C( 1, 2, 3 ), 4 ], [ 5, 6 ] ].b
    assert_equal M[ [ 1, 4 ], [ 5, 6 ] ],
                 M[ [ C( 1, 2, 3 ), 4 ], [ 5, 6 ] ].collect { |x| x.r }
    assert_equal M[ [ 2, 4 ], [ 5, 6 ] ],
                 M[ [ C( 1, 2, 3 ), 4 ], [ 5, 6 ] ].collect { |x| x.g }
    assert_equal M[ [ 3, 4 ], [ 5, 6 ] ],
                 M[ [ C( 1, 2, 3 ), 4 ], [ 5, 6 ] ].collect { |x| x.b }
  end

  def test_real_imag
    assert_equal M[ [ 1, 3 ], [ 4, 5 ] ], M[ [ X( 1, 2 ), 3 ], [ 4, 5 ] ].real
    assert_equal M[ [ 2, 0 ], [ 0, 0 ] ], M[ [ X( 1, 2 ), 3 ], [ 4, 5 ] ].imag
    assert_equal M[ [ 1, 3 ], [ 4, 5 ] ],
                 M[ [ X( 1, 2 ), 3 ], [ 4, 5 ] ].collect { |x| x.real }
    assert_equal M[ [ 2, 0 ], [ 0, 0 ] ],
                 M[ [ X( 1, 2 ), 3 ], [ 4, 5 ] ].collect { |x| x.imag }
  end

  def test_inject
    assert_equal 21, M[ [ 1, 2, 3 ], [ 4, 5, 6 ] ].inject { |a,b| a + b }
    assert_equal 28, M[ [ 1, 2, 3 ], [ 4, 5, 6 ] ].inject( 7 ) { |a,b| a + b }
  end

  def test_collect
    assert_equal M[ [ 2, 3, 4 ], [ 5, 6, 7 ] ], 
                 M[ [ 1, 2, 3 ], [ 4, 5, 6 ] ].collect { |x| x + 1 }
    assert_equal M[ [ 6 ] ], M[ [ C( 1, 2, 3 ) ] ].collect { |x| x.r + x.g + x.b }
  end

  def test_sum
    m = M[ [ 1, 2, 3 ], [ 4, 5, 6 ] ]
    assert_equal 21, sum { |i,j| m[ i, j ] }
    assert_equal [ 5, 7, 9 ], sum { |i| m[ i ] }.to_a
    assert_equal [ 6, 15 ], eager { |j| sum { |i| m[ i, j ] } }.to_a
    assert_equal [ [ 1, 2, 3 ] , [ 4, 5, 6 ] ], sum { || m }.to_a
  end

  def test_min
    assert_equal 1, M[ [ 5, 3, 7 ], [ 2, 1, 6 ] ].min
  end

  def test_max
    assert_equal 7, M[ [ 5, 3, 7 ], [ 2, 1, 6 ] ].max
  end

  def test_sum
    assert_equal 24, M[ [ 5, 3, 7 ], [ 2, 1, 6 ] ].sum
  end

  def test_range
    assert_equal 1 .. 7, M[ [ 5, 3, 7 ], [ 2, 1, 6 ] ].range
  end

  def test_diagonal
    assert_equal S[ 'b1a2', 'c1b2a3', 'c2b3' ],
                 M[ [ 'a1', 'a2', 'a3' ],
                    [ 'b1', 'b2', 'b3' ],
                    [ 'c1', 'c2', 'c3' ] ].diagonal { |a,b| a + b }
    assert_equal S[ 'c1b2a3', 'c2b3a4', 'c3b4' ],
                 M[ [ 'a1', 'a2', 'a3', 'a4' ],
                    [ 'b1', 'b2', 'b3', 'b4' ],
                    [ 'c1', 'c2', 'c3', 'c4' ] ].diagonal { |a,b| a + b }
    assert_equal S[ 'xb1a2', 'xc1b2a3', 'xd1c2b3', 'xd2c3' ],
                 M[ [ 'a1', 'a2', 'a3' ],
                    [ 'b1', 'b2', 'b3' ],
                    [ 'c1', 'c2', 'c3' ],
                    [ 'd1', 'd2', 'd3' ] ].diagonal( 'x' ) { |a,b| a + b }
    assert_equal S( I, 4 )[ 4, 12, 21, 18 ],
                 M( I, 3, 4 ).indgen.diagonal { |a,b| a + b }
    assert_equal S( I, 3 )[ 4, 12, 12 ],
                 M( I, 3, 3 ).indgen.diagonal { |a,b| a + b }
    assert_equal S( I, 2 )[ 4, 6 ],
                 M( I, 3, 2 ).indgen.diagonal { |a,b| a + b }
  end

  def test_convolve
    f = M[ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ]
    assert_equal M[ [ 5, 6, 0 ], [ 8, 9, 0 ], [ 0, 0, 0 ] ],
                 M[ [ 1, 0, 0 ], [ 0, 0, 0 ], [ 0, 0, 0 ] ].convolve( f )
    assert_equal M[ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ],
                 M[ [ 0, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 0 ] ].convolve( f )
    assert_equal M[ [ 0, 0, 0 ], [ 1, 2, 3 ], [ 4, 5, 6 ] ],
                 M[ [ 0, 0, 0 ], [ 0, 0, 0 ], [ 0, 1, 0 ] ].convolve( f )
    assert_raise( RuntimeError ) { S[ 1, 2, 3 ].convolve f }
    assert_raise( RuntimeError ) { M[ [ 1, 2, 3 ], [ 4, 5, 6 ] ].convolve S[ 1, 2 ] }
  end

  def test_histogram
    assert_equal S( I, 5 )[ 0, 1, 1, 2, 0 ],
                 M[ [ 1, 2 ], [ 3, 3 ] ].histogram( 5, :target => I )
    assert_equal M( I, 2, 2 )[ [ 1, 0 ], [ 1, 1 ] ],
                 M[ [ 0, 0 ], [ 0, 1 ], [ 1, 1 ] ].histogram( 2, 2, :target => I )
    #assert_equal M( I, 2, 2, 1 )[ [ [ 0, 1 ], [ 1, 0 ] ] ],
    #             S[ C( 1, 0, 0 ), C( 0, 1, 0 ) ].histogram( 2, 2, 1, :target => I )
    assert_raise( RuntimeError ) { S[ 1, 2, 3 ].histogram 4, 4 }
    assert_raise( RuntimeError ) { M[ [ -1, 0 ] ].histogram 3, 2 }
    assert_raise( RuntimeError ) { M[ [ 0, -1 ] ].histogram 3, 2 }
    assert_raise( RuntimeError ) { M[ [ 3, 0 ] ].histogram 3, 2 }
    assert_raise( RuntimeError ) { M[ [ 0, 2 ] ].histogram 3, 2 }
  end

  def test_lut
    assert_equal M[ [ 1, 2 ], [ 3, 1 ] ],
                 M[ [ 0, 1 ], [ 2, 0 ] ].lut( S[ 1, 2, 3, 4 ] )
    assert_equal M[ 1, 3, 4 ],
                 M[ [ 0, 0 ], [ 0, 1 ], [ 1, 1 ] ].lut( M[ [ 1, 2 ], [ 3, 4 ] ] )
    assert_equal M[ [ 3, 4 ], [ 1, 2 ] ],
                 M[ [ 1 ], [ 0 ] ].lut( M[ [ 1, 2 ], [ 3, 4 ] ] )
    assert_raise( RuntimeError ) { S[ 0, 1, 2 ].lut M[ [ 1, 2 ], [ 3, 4 ] ] }
    assert_raise( RuntimeError ) { M[ [ -1, 0 ] ].lut M[ [ 1, 2 ] ] }
    assert_raise( RuntimeError ) { M[ [ 0, -1 ] ].lut M[ [ 1, 2 ] ] }
    assert_raise( RuntimeError ) { M[ [ 2, 0 ] ].lut M[ [ 1, 2 ] ] }
    assert_raise( RuntimeError ) { M[ [ 0, 1 ] ].lut M[ [ 1, 2 ] ] }
    assert_raise( RuntimeError ) { M[ [ 1 ], [ 2 ] ].lut M[ [ 1, 2 ], [ 3, 4 ] ] }
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
    assert_equal M[ [ 2, 3, 4 ], [ 6, 7, 8 ] ],
                 M[ [ 1, 2, 3 ], [ 4, 5, 6 ] ] + S[ 1, 2 ]
    assert_equal M[ [ 2, 3, 4 ], [ 6, 7, 8 ] ],
                 S[ 1, 2 ] + M[ [ 1, 2, 3 ], [ 4, 5, 6 ] ]
    assert_raise( RuntimeError ) do
      M[ [ 1, 2, 3 ], [ 4, 5, 6 ] ] + M[ [ 1, 2 ], [ 3, 4 ] ]
    end
    assert_raise( RuntimeError ) do
      M[ [ 1, 2, 3 ], [ 4, 5, 6 ] ] + M[ [ 1, 2, 3 ] ]
    end
    assert_raise( RuntimeError ) do
      M[ [ 1, 2 ], [ 3, 4 ] ] + M[ [ 1, 2, 3 ], [ 4, 5, 6 ] ] 
    end
    assert_raise( RuntimeError ) do
      M[ [ 1, 2, 3 ] ] + M[ [ 1, 2, 3 ], [ 4, 5, 6 ] ]
    end
    assert_raise( RuntimeError ) do
      M[ [ 1, 2, 3 ], [ 4, 5, 6 ] ] + S[ 1, 2, 3 ]
    end
    assert_raise( RuntimeError ) do
      S[ 1, 2, 3 ] + M[ [ 1, 2, 3 ], [ 4, 5, 6 ] ]
    end
  end

  def test_major
    assert_equal M[ [ 4, 2 ], [ 3, 4 ] ],
                 M[ [ 1, 2 ], [ 3, 4 ] ].major( M[ [ 4, 1 ], [ 3, 2 ] ] )
  end

  def test_minor
    assert_equal M[ [ 1, 1 ], [ 3, 2 ] ],
                 M[ [ 1, 2 ], [ 3, 4 ] ].minor( M[ [ 4, 1 ], [ 3, 2 ] ] )
  end

  def test_cond
    assert_equal M[ [ -1, 2 ], [ 3, -4 ] ],
                 M[ [ false, true ], [ true, false ] ].
                 conditional( M[ [ 1, 2 ], [ 3, 4 ] ],
                              M[ [ -1, -2 ], [ -3, -4 ] ] )
    assert_equal M[ [ -1, -2 ], [ 3, 4 ] ],
                 S[ false, true ].
                 conditional( M[ [ 1, 2 ], [ 3, 4 ] ],
                              M[ [ -1, -2 ], [ -3, -4 ] ] )
    assert_equal M[ [ -1, -1 ], [ 3, 4 ] ],
                 S[ false, true ].
                 conditional( M[ [ 1, 2 ], [ 3, 4 ] ], -1 )
    assert_equal M[ [ -1, -1 ], [ 3, 4 ] ],
                 S[ false, true ].
                 conditional( M[ [ 1, 2 ], [ 3, 4 ] ], S[ -1, -2 ] )
  end

  def test_cmp
    assert_equal M[ [ -1, -1 ], [ 0, 1 ] ], M[ [ 1, 2 ], [ 3, 4 ] ] <=> 3
    assert_equal M[ [ 1, 1 ], [ 0, -1 ] ], 3 <=> M[ [ 1, 2 ], [ 3, 4 ] ]
  end

  def test_fill
    m = M( I, 3, 2 )[ [ 1, 2, 3 ], [ 4, 5, 6 ] ]
    assert_equal M( I, 3, 2 )[ [ 1, 1, 1 ], [ 1, 1, 1 ] ], m.fill!( 1 )
    assert_equal M( I, 3, 2 )[ [ 1, 1, 1 ], [ 1, 1, 1 ] ], m
  end

  def test_to_type
    assert_equal M( C, 2, 2 )[ [ 1, 2 ], [ 3, 4 ] ],
                 M( I, 2, 2 )[ [ 1, 2 ], [ 3, 4 ] ].to_intrgb
  end

  def test_integral
    assert_equal M( O, 3, 2 )[ [ 1, 3, 6 ], [ 5, 12, 21 ] ],
                 M( O, 3, 2 )[ [ 1, 2, 3 ], [ 4, 5, 6 ] ].integral
    assert_equal M( I, 3, 2 )[ [ 1, 3, 6 ], [ 5, 12, 21 ] ],
                 M( I, 3, 2 )[ [ 1, 2, 3 ], [ 4, 5, 6 ] ].integral
  end

end
