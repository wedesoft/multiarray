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

class TC_RGB < Test::Unit::TestCase

  BYTERGB   = Hornetseye::BYTERGB
  UBYTERGB  = Hornetseye::UBYTERGB
  SINTRGB   = Hornetseye::SINTRGB
  USINTRGB  = Hornetseye::USINTRGB
  INTRGB    = Hornetseye::INTRGB
  UINTRGB   = Hornetseye::UINTRGB
  LONGRGB   = Hornetseye::LONGRGB
  ULONGRGB  = Hornetseye::ULONGRGB

  def setup
  end

  def teardown
  end

  def test_rgb_inspect
    assert_equal 'BYTERGB', BYTERGB.inspect
    assert_equal 'UBYTERGB', UBYTERGB.inspect
    assert_equal 'SINTRGB', SINTRGB.inspect
    assert_equal 'USINTRGB', USINTRGB.inspect
    assert_equal 'INTRGB', INTRGB.inspect
    assert_equal 'UINTRGB', UINTRGB.inspect
    assert_equal 'LONGRGB', LONGRGB.inspect
    assert_equal 'ULONGRGB', ULONGRGB.inspect
  end

  def test_rgb_to_s
    assert_equal 'BYTERGB', BYTERGB.to_s
    assert_equal 'UBYTERGB', UBYTERGB.to_s
    assert_equal 'SINTRGB', SINTRGB.to_s
    assert_equal 'USINTRGB', USINTRGB.to_s
    assert_equal 'INTRGB', INTRGB.to_s
    assert_equal 'UINTRGB', UINTRGB.to_s
    assert_equal 'LONGRGB', LONGRGB.to_s
    assert_equal 'ULONGRGB', ULONGRGB.to_s
  end

  def test_rgb_default
    assert_equal RGB( 0, 0, 0 ), INTRGB.new[]
  end

end
