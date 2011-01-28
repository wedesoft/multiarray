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
  F = Hornetseye::DFLOAT
  S = Hornetseye::Sequence
  C = Hornetseye::INTRGB
  X = Hornetseye::DCOMPLEX
  Malloc = Hornetseye::Malloc

  def S( *args )
    Hornetseye::Sequence *args
  end

  def C( *args )
    Hornetseye::RGB *args
  end

  def X( *args )
    Complex *args
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
    assert_equal [ nil ] * 3, S( O, 3 ).default.to_a
    assert_equal [ 0 ] * 3, S( I, 3 ).default.to_a
    assert_equal [ C( 0, 0, 0 ) ] * 3, S( C, 3 ).default.to_a
  end

  def test_sequence_indgen
    assert_equal S( I, 3 )[ 0, 1, 2 ], S( I, 3 ).indgen
    assert_equal S( I, 3 )[ 1, 2, 3 ], S( I, 3 ).indgen( 1 )
    assert_equal S( I, 3 )[ 0, 2, 4 ], S( I, 3 ).indgen( 0, 2 )
    assert_equal S( I, 3 )[ 1, 3, 5 ], S( I, 3 ).indgen( 1, 2 )
    assert_equal S( C, 2 )[ C( 1, 2, 3 ), C( 3, 5, 7 ) ],
                 S( C, 2 ).indgen( C( 1, 2, 3 ), C( 2, 3, 4 ) )
  end

  def test_sequence_random
    r = S( O, 100 ).random( 10 ).range
    assert r.begin >= 0
    assert r.end < 10
    r = S( I, 100 ).random( 10 ).range
    assert r.begin >= 0
    assert r.end < 10
    r = S( F, 100 ).random( 10.0 ).range
    assert r.begin >= 0
    assert r.end < 10
  end

  def test_sequence_at
    assert_equal "Sequence(INT,3):\n[ 1, 2, 3 ]",
                 S( I, 3 )[ 1, 2, 3 ].inspect
    assert_equal "Sequence(OBJECT,3):\n[ 1, 2, 3 ]",
                 S( O, 3 )[ 1, 2, 3 ].inspect
    assert_equal "Sequence(INTRGB,2):\n[ RGB(1,2,3), RGB(4,5,6) ]",
                 S( C, 2 )[ C( 1, 2, 3 ), C( 4, 5, 6 ) ].inspect
  end

  def test_sequence_match
    assert_equal [ 1, 2, 3 ], S[ 1, 2, 3 ].to_a
    assert_equal O, S[ :a ].typecode
    assert_equal B, S[ false, true ].typecode
    assert_equal I, S[ -2 ** 31, 2 ** 31 - 1 ].typecode
    assert_equal C, S[ C( -2 ** 31, 2 ** 31 - 1, 0 ) ].typecode
    assert_equal X, S[ X( 1.5, 2.5 ) ].typecode
  end

  def test_sequence_typecode
    assert_equal O, S( O, 3 ).typecode
    assert_equal B, S( B, 3 ).typecode
    assert_equal I, S( I, 3 ).typecode
    assert_equal C, S( C, 3 ).typecode
    assert_equal X, S( X, 3 ).typecode
  end

  def test_sequence_dimension
    assert_equal 1, S( O, 3 ).dimension
  end

  def test_sequence_shape
    assert_equal [ 3 ], S( O, 3 ).shape
  end

  def test_sequence_size
    assert_equal 3, S( O, 3 ).size
    assert_equal 3, S( C, 3 ).size
  end

  def test_inspect
    assert_equal "Sequence(OBJECT,0):\n[]", S[].inspect
    assert_equal "Sequence(OBJECT,3):\n[ :a, 2, 3 ]", S[ :a, 2, 3 ].inspect
  end

  def test_dup
    s = S[ 1, 2, 3 ]
    v = s.dup
    v[ 1 ] = 0
    assert_equal S[ 1, 2, 3 ], s
  end

  def test_typecode
    assert_equal O, S.object( 3 ).typecode
    assert_equal I, S.int( 3 ).typecode
  end

  def test_dimension
    assert_equal 1, S[ 1, 2, 3 ].dimension
    assert_equal 1, S[ C( 1, 2, 3 ) ].dimension
  end

  def test_shape
    assert_equal [ 3 ], S[ 1, 2, 3 ].shape
  end

  def test_size
    assert_equal 3, S[ 1, 2, 3 ].size
  end

  def test_import
    str = "\001\000\000\000\002\000\000\000\003\000\000\000"
    assert_equal [ 1, 2, 3 ], S.import( I, str, 3 ).
                 to_a
    m = Malloc.new str.bytesize
    m.write str
    assert_equal [ 1, 2, 3 ], S.import( I, m, 3 ).to_a
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
      assert_raise( RuntimeError ) { s[ -1 ] }
      assert_raise( RuntimeError ) { s[ 3 ] }
      assert_raise( RuntimeError ) { s[ -1 ] = 0 }
      assert_raise( RuntimeError ) { s[ 3 ] = 0 }
      assert_raise( RuntimeError ) { s[ 0 ] = s }
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
      assert_nothing_raised { s[ 0 .. 3 ] }
      assert_nothing_raised { s[ 0 ... 4 ] }
      assert_raise( RuntimeError ) { s[ -1 .. 1 ] }
      assert_raise( RuntimeError ) { s[ 2 .. 4 ] }
      assert_raise( RuntimeError ) { s[ -1 ... 1 ] }
      assert_raise( RuntimeError ) { s[ 2 ... 5 ] }
      assert_nothing_raised { s[ 0 .. 3 ] = 0 }
      assert_nothing_raised { s[ 0 ... 4 ] = 0 }
      assert_raise( RuntimeError ) { s[ -1 .. 1 ] = 0 }
      assert_raise( RuntimeError ) { s[ 2 .. 4 ] = 0 }
      assert_raise( RuntimeError ) { s[ -1 ... 1 ] = 0 }
      assert_raise( RuntimeError ) { s[ 2 ... 5 ] = 0 }
      assert_raise( RuntimeError ) { s[ 1 .. 3 ] = s[ 1 .. 2 ] }
    end
  end

  def test_view
    [ S( O, 4 ), S( I, 4 ) ].each do |t|
      s = t[ 1, 2, 3, 4 ]
      v = s[ 1 .. 2 ]
      v[] = 0
      assert_equal [ 1, 0, 0, 4 ], s.to_a
    end
  end

  def test_equal
    assert_equal S[ 2, 3, 5 ], S[ 2, 3, 5 ]
    assert_not_equal S[ 2, 3, 5 ], S[ 2, 3, 7 ]
    assert_equal S[ X( 1, 2 ), 3 ], S[ X( 1, 2 ), X( 3, 0 ) ]
    assert_not_equal S[ X( 1, 2 ), 3 ], S[ X( 1, 3 ), 3 ]
    assert_not_equal S[ 2, 3, 5 ], S[ 2, 3 ]
    assert_not_equal S[ 2, 3, 5 ], S[ 2, 3, 5, 7 ]
    assert_not_equal S[ 2, 2, 2 ], 2
  end

  def test_r_g_b
    [ S( O, 3 ), S( C, 3 ) ].each do |t|
      assert_equal [ 1, 4, 5 ], t[ C( 1, 2, 3 ), 4, 5 ].r.to_a
      assert_equal [ 2, 4, 5 ], t[ C( 1, 2, 3 ), 4, 5 ].g.to_a
      assert_equal [ 3, 4, 5 ], t[ C( 1, 2, 3 ), 4, 5 ].b.to_a
      assert_equal [ 1, 4, 5 ], t[ C( 1, 2, 3 ), 4, 5 ].collect { |x| x.r }.to_a
      assert_equal [ 2, 4, 5 ], t[ C( 1, 2, 3 ), 4, 5 ].collect { |x| x.g }.to_a
      assert_equal [ 3, 4, 5 ], t[ C( 1, 2, 3 ), 4, 5 ].collect { |x| x.b }.to_a
      assert_equal t[ C( 3, 2, 1 ), 4, 5 ], t[ C( 1, 2, 3 ), 4, 5 ].swap_rgb
      s = t[ 0, 0, 0 ]
      assert_equal 1, s.r = 1
      assert_equal S[ 1, 2, 3 ], s.g = S[ 1, 2, 3 ]
      assert_equal S( O, 3 )[ 4, 5, 6 ], s.b = S( O, 3 )[ 4, 5, 6 ]
      assert_equal t[ C( 1, 1, 4 ), C( 1, 2, 5 ), C( 1, 3, 6 ) ], s
      assert_raise( RuntimeError ) { s.r = S[ 1, 2 ] }
      assert_raise( RuntimeError ) { s.g = S[ 1, 2 ] }
      assert_raise( RuntimeError ) { s.b = S[ 1, 2, 3, 4 ] }
    end
    assert_equal S[ 1, 2 ], S[ 1, 2 ].r
    assert_equal S[ 1, 2 ], S[ 1, 2 ].g
    assert_equal S[ 1, 2 ], S[ 1, 2 ].b
    assert_raise( RuntimeError ) { S[ 1, 2 ].r = 1 }
  end

  def test_real_imag
    [ S( O, 2 ), S( X, 2 ) ].each do |t|
      assert_equal [ 1, 3 ], t[ X( 1, 2 ), 3 ].real.to_a
      assert_equal [ 2, 0 ], t[ X( 1, 2 ), 3 ].imag.to_a
      assert_equal [ 1, 3 ], t[ X( 1, 2 ), 3 ].collect { |x| x.real }.to_a
      assert_equal [ 2, 0 ], t[ X( 1, 2 ), 3 ].collect { |x| x.imag }.to_a
      s = t[ 0, 0 ]
      assert_equal 1, s.real = 1
      assert_equal S[ 2, 3 ], s.imag = S[ 2, 3 ]
      assert_equal t[ X( 1, 2 ), X( 1, 3 ) ], s
      assert_raise( RuntimeError ) { s.real = S[ 1 ] }
      assert_raise( RuntimeError ) { s.imag = S[ 1, 2, 3 ] }
    end
    assert_equal S[ 1, 2 ], S[ 1, 2 ].real
    assert_equal S[ 0, 0 ], S[ 1, 2 ].imag
    s = S[ 1, 2 ]
    assert_equal S[ 3, 4 ], s.real = S[ 3, 4 ]
    assert_equal S[ 3, 4 ], s
    assert_raise( RuntimeError ) { S[ 1, 2 ].real = S[ 1, 2, 3 ] }
    assert_raise( RuntimeError ) { S[ 1, 2 ].imag = S[ 0, 0 ] }
  end

  def test_inject
    assert_equal 6, S[ 1, 2, 3 ].inject { |a,b| a + b }
    assert_equal 10, S[ 1, 2, 3 ].inject( 4 ) { |a,b| a + b }
    assert_equal 'abc', S[ 'a', 'b', 'c' ].inject { |a,b| a + b }
    assert_equal 'abcd', S[ 'b', 'c', 'd' ].inject( 'a' ) { |a,b| a + b }
    assert_equal C( 3, 5, 8 ), S[ C( 1, 2, 3 ), C( 2, 3, 5 ) ].inject { |a,b| a + b }
    assert_equal C( 5, 6, 8 ), S[ C( 1, 2, 3 ), C( 2, 3, 5 ) ].
                               inject( C( 2, 1, 0 ) ) { |a,b| a + b }
    assert_equal C( 7, 8, 9 ), S[ 1, 2, 3 ].inject( C( 1, 2, 3 ) ) { |a,b| a + b }
    assert_equal C( 4, 6, 9 ), S[ C( 1, 2, 3 ), C( 2, 3, 5 ) ].
                               inject( 1 ) { |a,b| a + b }
    assert_equal X( -5, 10 ), S( X, 2 )[ X( 1, 2 ), X( 3, 4 ) ].inject { |a,b| a * b }
    assert_raise( RuntimeError ) { S[].inject { |a,b| a + b } }
    assert_equal 0, S[].inject( 0 ) { |a,b| a + b }
  end

  def test_collect
    assert_equal S[ 2, 3 ], S[ 1, 2 ].collect { |x| x + 1 }
    assert_equal S[ 2, 4 ], S[ 1, 2 ].map { |x| 2 * x }
    assert_equal S[ 6 ], S[ C( 1, 2, 3 ) ].collect { |x| x.r + x.g + x.b }
  end

  def test_each
    a = []
    S[ 1, 2, 3 ].each { |x| a << x }
    assert_equal [ 1, 2, 3 ], a
  end

  def test_sum
    [ S( O, 3 ), S( I, 3 ) ].each do |t|
      assert_equal 6, t[ 1, 2, 3 ].sum
      assert_equal 6, sum { |i| t[ 1, 2, 3 ][ i ] }
      assert_equal [ 1, 2, 3 ], sum { || t[ 1, 2, 3 ] }.to_a
    end
    assert_equal C( 3, 5, 8 ), S[ C( 1, 2, 3 ), C( 2, 3, 5 ) ].sum
    assert_equal C( 3, 5, 8 ), sum { |i| S[ C( 1, 2, 3 ), C( 2, 3, 5 ) ][i] }
    assert_equal X( 4, 6 ), S[ X( 1, 2 ), X( 3, 4 ) ].sum
    assert_equal X( 4, 6 ), sum { |i| S[ X( 1, 2 ), X( 3, 4 ) ][i] }
    assert_equal 384, S[ 128, 128, 128 ].sum
    assert_equal 384, sum { |i| S[ 128, 128, 128 ][i] }
  end

  def test_min
    [ O, I ].each do |t|
      assert_equal 2, S( t, 3 )[ 4, 2, 3 ].min
    end
    assert_equal C( 1, 2, 1 ), S[ C( 1, 2, 3 ), C( 3, 2, 1 ) ].min
  end

  def test_max
    [ O, I ].each do |t|
      assert_equal 4, S( t, 3 )[ 4, 2, 3 ].max
    end
    assert_equal C( 3, 2, 3 ), S[ C( 1, 2, 3 ), C( 3, 2, 1 ) ].max
  end

  def test_between
    assert_equal S[ false, true, true, false ], S[ 1, 2, 3, 4 ].between?( 2, 3 )
  end

  def test_normalise
    assert_equal [ 0.0, 85.0, 255.0 ], S[ 1, 2, 4 ].normalise.to_a
    assert_equal [ C( 0.0, 85.0, 255.0 ) ], S[ C( 1, 2, 4 ) ].normalise.to_a
  end

  def test_clip
    assert_equal [ 0, 1, 3, 4 ], S[ -1, 1, 3, 5 ].clip( 0 .. 4 ).to_a
    assert_equal [ C( 3, 4, 5 ) ], S[ C( 2, 4, 6 ) ].clip( 3 .. 5 ).to_a
  end

  def test_sum
    [ S( O, 3 ), S( I, 3 ) ].each do |t|
      assert_equal 9, t[ 4, 2, 3 ].sum
    end
    assert_equal C( 4, 4, 4 ), S[ C( 1, 2, 3 ), C( 3, 2, 1 ) ].sum
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
    assert_equal S[ C( 1, 0, 0 ), C( 2, 1, 0 ), C( 3, 2, 1 ), C( 0, 3, 2 ),
                    C( 0, 0, 3 ) ],
                 S[ 0, 1, 2, 3, 0 ].
                 convolve( S[ C( 1, 0, 0 ), C( 0, 1, 0 ), C( 0, 0, 1 ) ] )
  end

  def test_erode
    [ O, I ].each do |t|
      assert_equal [ 1, 1, 1, 2, 2, 2 ], S( t, 6 )[ 1, 1, 2, 3, 2, 2 ].erode.to_a
    end
    assert_equal S[ false, false, true, false, false ],
                 S[ false, true, true, true, false ].erode
  end

  def test_dilate
    [ O, I ].each do |t|
      assert_equal [ 1, 2, 3, 3, 3, 2 ], S( t, 6 )[ 1, 1, 2, 3, 2, 2 ].dilate.to_a
    end
    assert_equal S[ false, true, true, true, false ],
                 S[ false, false, true, false, false ].dilate
  end

  def test_sobel
    assert_equal [ 0, -1, 0, 1, 0 ], S[ 0, 0, 1, 0, 0 ].sobel( 0 ).to_a
  end

  def test_histogram
    [ O, I ].each do |t|
      assert_equal [ 0, 1, 2, 1, 1 ],
                   S( t, 5 )[ 1, 2, 2, 3, 4 ].histogram( 5, :weight => 1 ).to_a
      assert_equal S( t, 5 )[ 0, 1, 2, 3, 0 ],
                   S( t, 3 )[ 1, 3, 2 ].histogram( 5, :weight => S( t, 3 )[ 1, 3, 2 ] )
      assert_equal [ 0, 1, 1, 0 ],
                   S( t, 2 )[ 1.0, 2.0 ].histogram( 4, :weight => 1 ).to_a
    end
    assert_raise( RuntimeError ) { S[ -1, 0, 1 ].histogram 3 }
    assert_raise( RuntimeError ) { S[ 1, 2, 3 ].histogram 3 }
    assert_raise( RuntimeError ) { S[ 0, 0, 0 ].histogram 3, 2 }
    assert_raise( RuntimeError ) { S[ 0, 1 ].histogram 3, :weight => S[ 0 ] }
  end

  def test_lut
    [ O, I ].each do |t|
      assert_equal S( t, 4 )[ 3, 1, 2, 1 ],
                   S( t, 4 )[ 0, 2, 1, 2 ].lut( S( t, 3 )[ 3, 2, 1 ] )
      assert_equal S( t, 2 )[ 2, 1 ],
                   S( t, 2 )[ 1.0, 2.0 ].lut( S( t, 3 )[ 3, 2, 1 ] )
    end
    assert_raise( RuntimeError ) { S[ -1, 0 ].lut S[ 0, 1 ] }
    assert_raise( RuntimeError ) { S[ 1, 2 ].lut S[ 0, 1 ] }
  end

  def test_warp
    [ O, I ].each do |t1|
      [ O, I ].each do |t2|
        assert_equal S( t1, 3 )[ 1, 2, t1.default ],
                     S( t1, 2 )[ 1, 2 ].warp( S( t2, 3 )[ 0, 1, 2 ] )
      end
    end
  end

  def test_flip
    [ O, I ].each do |t|
      assert_equal S( t, 3 )[ 3, 2, 1 ], S( t, 3 )[ 1, 2, 3 ].flip( 0 )
    end
  end

  def test_shift
    [ O, I ].each do |t|
      assert_equal S( t, 3 )[ 1, 2, 3 ], S( t, 3 )[ 1, 2, 3 ].shift( 0 )
      assert_equal S( t, 3 )[ 3, 1, 2 ], S( t, 3 )[ 1, 2, 3 ].shift( 1 )
      assert_equal S( t, 3 )[ 2, 3, 1 ], S( t, 3 )[ 1, 2, 3 ].shift( 2 )
    end
  end

  def test_downsample
    [ O, I ].each do |t|
      assert_equal S( t, 2 )[ 2, 4 ],
                   S( t, 4 )[ 1, 2, 3, 4 ].downsample( 2 )
      assert_equal S( t, 2 )[ 1, 3 ],
                   S( t, 4 )[ 1, 2, 3, 4 ].downsample( 2, :offset => [ 0 ] )
    end
  end

  def test_zero
    [ S( O, 3 ), S( I, 3 ) ].each do |t|
      assert_equal [ false, true, false ], t[ -1, 0, 1 ].zero?.to_a
    end
    assert_equal S[ false, false, false, true ],
                 S[ C( 1, 0, 0 ), C( 0, 1, 0 ), C( 0, 0, 1 ), C( 0, 0, 0 ) ].zero?
    assert_equal S[ true, false, false ],
                 S[ X( 0, 0 ), X( 1, 0 ), X( 0, 1 ) ].zero?
  end

  def test_nonzero
    assert_equal S[ true, false, true ], S( I, 3 )[ -1, 0, 1 ].nonzero?
    assert_equal S[ -1, nil, 1 ], S( O, 3 )[ -1, 0, 1 ].nonzero?
    assert_equal S[ true, true, true, false ],
                 S[ C( 1, 0, 0 ), C( 0, 1, 0 ), C( 0, 0, 1 ), C( 0, 0, 0 ) ].nonzero?
    assert_equal S[ false, true, true ],
                 S[ X( 0, 0 ), X( 1, 0 ), X( 0, 1 ) ].nonzero?
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
    assert_equal [ C( -2, -3, -4 ), C( -5, -6, -7 ) ],
                 ( ~S( C, 2 )[ C( 1, 2, 3 ), C( 4, 5, 6 ) ] ).to_a
  end

  def test_bitwise_and
    [ S( O, 3 ), S( I, 3 ) ].each do |t|
      assert_equal [ 0, 1, 0 ], ( t[ 0, 1, 2 ] & 1 ).to_a
      assert_equal [ 0, 1, 0 ], ( 1 & t[ 0, 1, 2 ] ).to_a
      assert_equal [ 0, 1, 2 ], ( t[ 0, 1, 3 ] & t[ 4, 3, 2 ] ).to_a
    end
    assert_equal [ C( 0, 2, 2 ) ], ( S( C, 1 )[ C( 1, 2, 3 ) ] & 2 ).to_a
    assert_equal [ C( 1, 0, 1 ) ], ( 1 & S( C, 1 )[ C( 1, 2, 3 ) ] ).to_a
    assert_equal [ C( 1, 2, 1 ) ], ( S( C, 1 )[ C( 1, 2, 3 ) ] & C( 3, 2, 1 ) ).to_a
  end

  def test_bitwise_or
    [ S( O, 3 ), S( I, 3 ) ].each do |t|
      assert_equal [ 1, 1, 3 ], ( t[ 0, 1, 2 ] | 1 ).to_a
      assert_equal [ 1, 1, 3 ], ( 1 | t[ 0, 1, 2 ] ).to_a
      assert_equal [ 4, 3, 3 ], ( t[ 0, 1, 2 ] | t[ 4, 3, 1 ] ).to_a
    end
    assert_equal [ C( 3, 2, 3 ) ], ( S( C, 1 )[ C( 1, 2, 3 ) ] | 2 ).to_a
    assert_equal [ C( 1, 3, 3 ) ], ( 1 | S( C, 1 )[ C( 1, 2, 3 ) ] ).to_a
    assert_equal [ C( 3, 2, 3 ) ], ( S( C, 1 )[ C( 1, 2, 3 ) ] | C( 3, 2, 1 ) ).to_a
  end

  def test_bitwise_xor
    [ S( O, 3 ), S( I, 3 ) ].each do |t|
      assert_equal [ 1, 0, 3 ], ( t[ 0, 1, 2 ] ^ 1 ).to_a
      assert_equal [ 1, 0, 3 ], ( 1 ^ t[ 0, 1, 2 ] ).to_a
      assert_equal [ 4, 2, 3 ], ( t[ 0, 1, 2 ] ^ t[ 4, 3, 1 ] ).to_a
    end
    assert_equal [ C( 3, 0, 1 ) ], ( S( C, 1 )[ C( 1, 2, 3 ) ] ^ 2 ).to_a
    assert_equal [ C( 0, 3, 2 ) ], ( 1 ^ S( C, 1 )[ C( 1, 2, 3 ) ] ).to_a
    assert_equal [ C( 2, 0, 2 ) ], ( S( C, 1 )[ C( 1, 2, 3 ) ] ^ C( 3, 2, 1 ) ).to_a
  end

  def test_shl
    [ S( O, 3 ), S( I, 3 ) ].each do |t|
      assert_equal [ 2, 4, 6 ], ( t[ 1, 2, 3 ] << 1 ).to_a
      assert_equal [ 6, 12, 24 ], ( 3 << t[ 1, 2, 3 ] ).to_a
      assert_equal [ 8, 8, 6 ], ( t[ 1, 2, 3 ] << t[ 3, 2, 1 ] ).to_a
    end
  end

  def test_shr
    [ S( O, 3 ), S( I, 3 ) ].each do |t|
      assert_equal [ 1, 2, 3 ], ( t[ 2, 4, 6 ] >> 1 ).to_a
      assert_equal [ 12, 6, 3 ], ( 24 >> t[ 1, 2, 3 ] ).to_a
      assert_equal [ 2, 1, 3 ], ( t[ 16, 4, 6 ] >> t[ 3, 2, 1 ] ).to_a
    end
  end

  def test_negate
    [ S( O, 3 ), S( I, 3 ) ].each do |t|
      assert_equal t[ -1, 2, -3 ], -t[ 1, -2, 3 ]
    end
    assert_equal S( C, 2 )[ C( -1, -2, -3 ), C( -2, -1, 0 ) ],
                 -S( C, 2 )[ C( 1, 2, 3 ), C( 2, 1, 0 ) ]
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
    assert_equal S[ X( 4, 6 ) ], S[ X( 1, 2 ) ] + S[ X( 3, 4 ) ]
    assert_raise( RuntimeError ) { S[ 1, 2, 3 ] + S[ 1, 2 ] }
    assert_raise( RuntimeError ) { S[ 1, 2 ] + S[ 1, 2, 3 ] }
  end

  def test_minus
    assert_equal S[ 1, 2, 4 ], S[ 2, 3, 5 ] - 1
    assert_equal S[ 1, 2, 4 ], 5 - S[ 4, 3, 1 ]
    assert_equal S[ 1, 2, 3 ], S[ 2, 3, 5 ] - S[ 1, 1, 2 ]
    assert_equal S[ C( 1, 2, 3 ), C( 4, 5, 6 ) ], S[ C( 2, 3, 4 ), C( 5, 6, 7 ) ] - 1
    assert_equal S[ C( 6, 5, 4 ), C( 3, 2, 1 ) ], 7 - S[ C( 1, 2, 3 ), C( 4, 5, 6 ) ]
    assert_equal S[ C( 3, 2, 1 ), C( 4, 3, 2 ) ], S[ 4, 5 ] - C( 1, 2, 3 )
    assert_equal S[ X( -1.0, 2.0 ) ], -S[ X( 1.0, -2.0 ) ]
  end

  def test_conj
    assert_equal S( O, 2 )[ 1.5, 2.5 ], S( O, 2 )[ 1.5, 2.5 ].conj
    assert_equal S( F, 2 )[ 1.5, 2.5 ], S( F, 2 )[ 1.5, 2.5 ].conj
    assert_equal S[ X( 1.5, -2.5 ) ], S[ X( 1.5, 2.5 ) ].conj
  end

  def test_abs
    assert_equal [ 1, 0, 1 ], S[ -1, 0, 1 ].abs.to_a
    assert_equal [ 5 ], S[ X( 3, 4 ) ].abs.to_a
  end

  def test_arg
    [ 0.0, Math::PI ].zip( S[ 1, -1 ].arg.to_a ).each do |x,y|
      assert_in_delta x, y, 1.0e-5
    end
    r = S[ X( 1, 0 ), X( 0, 1 ), X( -1, 0 ), X( 0, -1 ) ].arg
    [ 0.0, Math::PI / 2, Math::PI, -Math::PI / 2 ].zip( r.to_a ).each do |x,y|
      assert_in_delta x, y, 1.0e-5
    end
  end

  def test_mul
    assert_equal S[ 6, 12, 20 ], S[ 2, 3, 4 ] * S[ 3, 4, 5 ]
    assert_equal S[ C( -2, 0, 4 ) ], S[ C( 2, 3, 4 ) ] * S[ C( -1, 0, 1 ) ]
    assert_equal S[ X( -11, 2 ) ], S[ X( -1, 2 ) ] * S[ X( 3, 4 ) ]
  end

  def test_div
    assert_equal S[ 2, 3, 4 ], S[ 6, 12, 20 ] / S[ 3, 4, 5 ]
    assert_equal S[ X( -1, 2 ) ], S[ X( -11, 2 ) ] / S[ X( 3, 4 ) ]
  end

  def test_mod
    assert_equal S[ 2, 0, 1 ], S[ 2, 3, 4 ] % 3
  end

  def test_pow
    assert_equal [ 1, 4, 9 ], ( S[ 1, 2, 3 ] ** 2 ).to_a
    assert_equal [ C( 2, 4, 8 ) ], ( 2 ** S[ C( 1, 2, 3 ) ] ).to_a
    assert_in_delta 0.0, ( ( S( X, 1 )[ X( 1, 2 ) ] ** 2 )[ 0 ] - X( -3, 4 ) ).abs,
                    1.0e-5
    assert_in_delta 0.0, ( Math::E ** S( X, 1 )[ X( 0, Math::PI ) ][ 0 ] + 1 ).abs,
                    1.0e-5
  end

  def test_eq
    assert_equal S[ false, true, false ], S[ 1, 2, 3 ].eq( 2 )
    assert_equal S[ false, true ],
                 S[ C( 1, 2, 1 ), C( 2, 1, 0 ) ].eq( S[ C( 1, 2, 3 ), C( 2, 1, 0 ) ] )
    assert_equal S[ false, true, false ],
                 X( 1, 2 ).eq( S[ X( 1, 1 ), X( 1, 2 ), X( 2, 2 ) ] )
  end

  def test_ne
    assert_equal S[ true, false, true ], S[ 1, 2, 3 ].ne( 2 )
  end

  def test_lt
    assert_equal S[ true, false, false ], S[ 1, 2, 3 ] < 2
  end

  def test_le
    assert_equal S[ true, true, false ], S[ 1, 2, 3 ] <= 2
  end

  def test_gt
    assert_equal S[ false, false, true ], S[ 1, 2, 3 ] > 2
  end

  def test_ge
    assert_equal S[ false, true, true ], S[ 1, 2, 3 ] >= 2
  end

  def test_floor
    assert_equal S[ 0.0, 0.0, 1.0 ], S[ 0.3, 0.7, 1.3 ].floor
    assert_equal S[ C( 0.0, 0.0, 1.0 ) ], S[ C( 0.3, 0.7, 1.3 ) ].floor
  end

  def test_ceil
    assert_equal S[ 1.0, 1.0, 2.0 ], S[ 0.3, 0.7, 1.3 ].ceil
    assert_equal S[ C( 1.0, 1.0, 2.0 ) ], S[ C( 0.3, 0.7, 1.3 ) ].ceil
  end

  def test_round
    assert_equal S[ 0.0, 1.0, 1.0 ], S[ 0.3, 0.7, 1.3 ].round
    assert_equal S[ C( 0.0, 1.0, 1.0 ) ], S[ C( 0.3, 0.7, 1.3 ) ].round
  end

  def test_cond
    assert_equal S[ 1, 2 ], S[ false, true ].conditional( 2, 1 )
    assert_equal S[ -1, 2 ], S[ false, true ].conditional( S[ 1, 2 ], -1 )
    assert_equal S[ -1, 1 ], S[ false, true ].conditional( 1, S[ -1, -2 ] )
    assert_equal S[ -1, 2 ], S[ false, true ].conditional( S[ 1, 2 ], S[ -1, -2 ] )
    assert_equal S[ C( 4, 5, 6 ), C( 1, 2, 3 ) ],
                 S[ false, true ].conditional( C( 1, 2, 3 ), C( 4, 5, 6 ) )
    assert_equal S[ X( 3, 4 ), X( 1, 2 ) ],
                 S[ false, true ].conditional( X( 1, 2 ), X( 3, 4 ) )
    assert_raise( RuntimeError ) { S[ false, true ].conditional( S[ 1, 2 ], S[ 1 ] ) }
    assert_raise( RuntimeError ) { S[ false, true ].conditional( S[ 1 ], S[ 1, 2 ] ) }
    assert_raise( RuntimeError ) { S[ false ].conditional( S[ 1, 2 ], S[ 1, 2 ] ) }
  end

  def test_cmp
    assert_equal S[ -1, 0, 1 ], S[ 1, 2, 3 ] <=> 2
    assert_equal S[ 1, 0, -1 ], 2 <=> S[ 1, 2, 3 ]
    assert_equal S[ -1, 0, 1 ], S[ 1, 3, 5 ] <=> S[ 2, 3, 4 ]
  end

  def test_major
    assert_equal [ 2, 2, 3 ], S[ 1, 2, 3 ].major( 2 ).to_a
    assert_equal [ 2, 2, 3 ], 2.major( S[ 1, 2, 3 ] ).to_a
    assert_equal [ 3, 2, 3 ], S[ 1, 2, 3 ].major( S[ 3, 2, 1 ] ).to_a
    assert_equal [ C( 2, 2, 3 ) ], S[ C( 1, 2, 3 ) ].major( 2 ).to_a
  end

  def test_minor
    assert_equal [ 1, 2, 2 ], S[ 1, 2, 3 ].minor( 2 ).to_a
    assert_equal [ 1, 2, 2 ], 2.minor( S[ 1, 2, 3 ] ).to_a
    assert_equal [ 1, 2, 1 ], S[ 1, 2, 3 ].minor( S[ 3, 2, 1 ] ).to_a
    assert_equal [ C( 1, 2, 2 ) ], S[ C( 1, 2, 3 ) ].minor( 2 ).to_a
  end

  def test_sqrt
    assert_equal S( O, 3 )[ 1, 2, 3 ], Math.sqrt( S( O, 3 )[ 1, 4, 9 ] )
    assert_equal S[ 1.0, 2.0, 3.0 ], Math.sqrt( S[ 1.0, 4.0, 9.0 ] )
    [ Math.sqrt( X( 1, 2 ) ), Math.sqrt( X( 2, -1 ) ) ].
      zip( Math.sqrt( S[ X( 1, 2 ), X( 2, -1 ) ] ).to_a ).each do |x,y|
      assert_in_delta x.real, y.real, 1.0e-5
      assert_in_delta x.imag, y.imag, 1.0e-5
    end
    [ Math.sqrt( C( 1, 2, 3 ) ), Math.sqrt( C( 2, 4, 6 ) ) ].
      zip( Math.sqrt( S[ C( 1, 2, 3 ), C( 2, 4, 6 ) ] ).to_a ).each do |x,y|
      assert_in_delta x.r, y.r, 1.0e-5
      assert_in_delta x.g, y.g, 1.0e-5
      assert_in_delta x.b, y.b, 1.0e-5
    end
  end

  def test_exp
    [ Math.exp( 2 ), Math.exp( 3 ) ].zip( Math.exp( S[ 2, 3 ] ).to_a ).each do |x,y|
      assert_in_delta x, y, 1.0e-5
    end
    [ Math.exp( X( 1, 2 ) ) ].zip( Math.exp( S[ X( 1, 2 ) ] ).to_a ).each do |x,y|
      assert_in_delta x.real, y.real, 1.0e-5
      assert_in_delta x.imag, y.imag, 1.0e-5
    end
  end

  def test_cos
    [ Math.cos( 2 ), Math.cos( 3 ) ].zip( Math.cos( S[ 2, 3 ] ).to_a ).each do |x,y|
      assert_in_delta x, y, 1.0e-5
    end
    [ Math.cos( X( 1, 2 ) ) ].zip( Math.cos( S[ X( 1, 2 ) ] ).to_a ).each do |x,y|
      assert_in_delta x.real, y.real, 1.0e-5
      assert_in_delta x.imag, y.imag, 1.0e-5
    end
  end

  def test_sin
    [ Math.sin( 2 ), Math.sin( 3 ) ].zip( Math.sin( S[ 2, 3 ] ).to_a ).each do |x,y|
      assert_in_delta x, y, 1.0e-5
    end
    [ Math.sin( X( 1, 2 ) ) ].zip( Math.sin( S[ X( 1, 2 ) ] ).to_a ).each do |x,y|
      assert_in_delta x.real, y.real, 1.0e-5
      assert_in_delta x.imag, y.imag, 1.0e-5
    end
  end

  def test_tan
    [ Math.tan( 2 ), Math.tan( 3 ) ].zip( Math.tan( S[ 2, 3 ] ).to_a ).each do |x,y|
      assert_in_delta x, y, 1.0e-5
    end
    [ Math.tan( X( 1, 2 ) ) ].zip( Math.tan( S[ X( 1, 2 ) ] ).to_a ).each do |x,y|
      assert_in_delta x.real, y.real, 1.0e-5
      assert_in_delta x.imag, y.imag, 1.0e-5
    end
  end

  def test_cosh
    [ Math.cosh( 2 ), Math.cosh( 3 ) ].
      zip( Math.cosh( S[ 2, 3 ] ).to_a ).each do |x,y|
      assert_in_delta x, y, 1.0e-5
    end
    [ Math.cosh( X( 1, 2 ) ) ].zip( Math.cosh( S[ X( 1, 2 ) ] ).to_a ).each do |x,y|
      assert_in_delta x.real, y.real, 1.0e-5
      assert_in_delta x.imag, y.imag, 1.0e-5
    end
  end

  def test_sinh
    [ Math.sinh( 2 ), Math.sinh( 3 ) ].
      zip( Math.sinh( S[ 2, 3 ] ).to_a ).each do |x,y|
      assert_in_delta x, y, 1.0e-5
    end
    [ Math.sinh( X( 1, 2 ) ) ].zip( Math.sinh( S[ X( 1, 2 ) ] ).to_a ).each do |x,y|
      assert_in_delta x.real, y.real, 1.0e-5
      assert_in_delta x.imag, y.imag, 1.0e-5
    end
  end

  def test_tanh
    [ Math.tanh( 2 ), Math.tanh( 3 ) ].
      zip( Math.tanh( S[ 2, 3 ] ).to_a ).each do |x,y|
      assert_in_delta x, y, 1.0e-5
    end
    [ Math.tanh( X( 1, 2 ) ) ].zip( Math.tanh( S[ X( 1, 2 ) ] ).to_a ).each do |x,y|
      assert_in_delta x.real, y.real, 1.0e-5
      assert_in_delta x.imag, y.imag, 1.0e-5
    end
  end

  def test_log
    [ Math.log( 2 ), Math.log( 3 ) ].zip( Math.log( S[ 2, 3 ] ).to_a ).each do |x,y|
      assert_in_delta x, y, 1.0e-5
    end
    [ Math.log( X( 1, 2 ) ) ].zip( Math.log( S[ X( 1, 2 ) ] ).to_a ).each do |x,y|
      assert_in_delta x.real, y.real, 1.0e-5
      assert_in_delta x.imag, y.imag, 1.0e-5
    end
  end

  def test_log10
    [ Math.log10( 2 ), Math.log10( 3 ) ].
      zip( Math.log10( S[ 2, 3 ] ).to_a ).each do |x,y|
      assert_in_delta x, y, 1.0e-5
    end
    [ Math.log10( X( 1, 2 ) ) ].zip( Math.log10( S[ X( 1, 2 ) ] ).to_a ).each do |x,y|
      assert_in_delta x.real, y.real, 1.0e-5
      assert_in_delta x.imag, y.imag, 1.0e-5
    end
  end

  def test_acos
    [ Math.acos( 0.3 ), Math.acos( 0.6 ) ].
      zip( Math.acos( S[ 0.3, 0.6 ] ).to_a ).each do |x,y|
      assert_in_delta x, y, 1.0e-5
    end
    [ Math.acos( X( 0.2, 0.3 ) ) ].
      zip( Math.acos( S[ X( 0.2, 0.3 ) ] ).to_a ).each do |x,y|
      assert_in_delta x.real, y.real, 1.0e-5
      assert_in_delta x.imag, y.imag, 1.0e-5
    end
  end

  def test_asin
    [ Math.asin( 0.3 ), Math.asin( 0.6 ) ].
      zip( Math.asin( S[ 0.3, 0.6 ] ).to_a ).each do |x,y|
      assert_in_delta x, y, 1.0e-5
    end
    [ Math.asin( X( 0.2, 0.3 ) ) ].
      zip( Math.asin( S[ X( 0.2, 0.3 ) ] ).to_a ).each do |x,y|
      assert_in_delta x.real, y.real, 1.0e-5
      assert_in_delta x.imag, y.imag, 1.0e-5
    end
  end

  def test_atan
    [ Math.atan( 0.3 ), Math.atan( 0.6 ) ].
      zip( Math.atan( S[ 0.3, 0.6 ] ).to_a ).each do |x,y|
      assert_in_delta x, y, 1.0e-5
    end
    [ Math.atan( X( 0.2, 0.3 ) ) ].
      zip( Math.atan( S[ X( 0.2, 0.3 ) ] ).to_a ).each do |x,y|
      assert_in_delta x.real, y.real, 1.0e-5
      assert_in_delta x.imag, y.imag, 1.0e-5
    end
  end

  def test_acosh
    [ Math.acosh( 1.3 ), Math.acosh( 1.6 ) ].
      zip( Math.acosh( S[ 1.3, 1.6 ] ).to_a ).each do |x,y|
      assert_in_delta x, y, 1.0e-5
    end
    [ Math.acosh( X( 1.2, 1.3 ) ) ].
      zip( Math.acosh( S[ X( 1.2, 1.3 ) ] ).to_a ).each do |x,y|
      assert_in_delta x.real, y.real, 1.0e-5
      assert_in_delta x.imag, y.imag, 1.0e-5
    end
  end

  def test_asinh
    [ Math.asinh( 1.3 ), Math.asinh( 1.6 ) ].
      zip( Math.asinh( S[ 1.3, 1.6 ] ).to_a ).each do |x,y|
      assert_in_delta x, y, 1.0e-5
    end
    [ Math.asinh( X( 1.2, 1.3 ) ) ].
      zip( Math.asinh( S[ X( 1.2, 1.3 ) ] ).to_a ).each do |x,y|
      assert_in_delta x.real, y.real, 1.0e-5
      assert_in_delta x.imag, y.imag, 1.0e-5
    end
  end

  def test_atanh
    [ Math.atanh( 0.3 ), Math.atanh( 0.6 ) ].
      zip( Math.atanh( S[ 0.3, 0.6 ] ).to_a ).each do |x,y|
      assert_in_delta x, y, 1.0e-5
    end
    [ Math.atanh( X( 0.2, 0.3 ) ) ].
      zip( Math.atanh( S[ X( 0.2, 0.3 ) ] ).to_a ).each do |x,y|
      assert_in_delta x.real, y.real, 1.0e-5
      assert_in_delta x.imag, y.imag, 1.0e-5
    end
  end

  def test_atan2
    [ Math.atan2( 3, 4 ), Math.atan2( 4, 3 ) ].
      zip( Math.atan2( S[ 3, 4 ], S[ 4, 3 ] ).to_a ).each do |x,y|
      assert_in_delta x, y, 1.0e-5
    end
    [ Math.atan2( X( 1, 2 ), X( 3, 4 ) ) ].
      zip( Math.atan2( S[ X( 1, 2 ) ], S[ X( 3, 4 ) ] ).to_a ).each do |x,y|
      assert_in_delta x.real, y.real, 1.0e-5
      assert_in_delta x.imag, y.imag, 1.0e-5
    end
    assert_raise( RuntimeError ) { Math.atan2( S[ 3 ], S[ 4, 3 ] ) }
    assert_raise( RuntimeError ) { Math.atan2( S[ 3, 4 ], S[ 4 ] ) }
  end

  def test_hypot
    assert_equal S[ 5.0, 5.0 ], Math.hypot( S[ 3, 4 ], S[ 4, 3 ] )
    assert_raise( RuntimeError ) { Math.hypot( S[ 3 ], S[ 4, 3 ] ) }
    assert_raise( RuntimeError ) { Math.hypot( S[ 3, 4 ], S[ 4 ] ) }
  end

  def test_fill
    [ S( O, 3 ), S( I, 3 ) ].each do |t|
      s = t[ 1, 2, 3 ]
      assert_equal t[ 1, 1, 1 ], s.fill!( 1 )
      assert_equal t[ 1, 1, 1 ], s
    end
  end

  def test_to_type
    assert_equal S( O, 3 )[ 1, 2, 3 ], S( I, 3 )[ 1, 2, 3 ].to_object
    assert_equal S( I, 3 )[ 1, 2, 3 ], S( O, 3 )[ 1, 2, 3 ].to_int
    assert_equal S( C, 3 )[ 1, 2, 3 ], S( I, 3 )[ 1, 2, 3 ].to_intrgb
  end

  def test_reshape
    [ O, I ].each do |t|
      assert_equal S( t, 3 )[ 1, 2, 3 ], S( t, 3 )[ 1, 2, 3 ].reshape( 3 )
      assert_raise( RuntimeError ) { S( t, 3 )[ 1, 2, 3 ].reshape 2 }
      assert_raise( RuntimeError ) { S( t, 3 )[ 1, 2, 3 ].reshape 4 }
    end
  end

  def test_integral
    assert_equal S( O, 3 )[ 1, 3, 6 ], S( O, 3 )[ 1, 2, 3 ].integral
    assert_equal S( I, 3 )[ 1, 3, 6 ], S( I, 3 )[ 1, 2, 3 ].integral
  end

  def test_mask
    assert_equal S( O, 2 )[ 2, 5 ], S( O, 3 )[ 2, 3, 5 ].
                 mask( S[ true, false, true ] )
    assert_equal S( I, 2 )[ 2, 5 ], S( I, 3 )[ 2, 3, 5 ].
                 mask( S[ true, false, true ] )
    assert_raise( RuntimeError ) { S[ 1, 2 ].mask S[ true ] }
  end

  def test_unmask
    [ O, I ].each do |t|
      assert_equal S( t, 3 )[ 2, 3, 5 ],
                   S( t, 2 )[ 2, 5 ].unmask( S[ true, false, true ], :default => 3 )
      assert_equal S( t, 3 )[ 2, 3, 5 ],
                   S( t, 2 )[ 2, 5 ].unmask( S[ true, false, true ],
                                             :default => S[ 2, 3, 4 ] )
      assert_raise( RuntimeError ) do
        S( t, 1 )[ 1 ].unmask S[ true ], :default => S[ 1, 2 ]
      end
      assert_raise( RuntimeError ) { S( t, 1 )[ 1 ].unmask S[ true, true ] }
    end
  end

end

