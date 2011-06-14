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

class TC_Compile < Test::Unit::TestCase

  B = Hornetseye::BYTE
  W = Hornetseye::SINT
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

  def finalise( *args, &action )
    Hornetseye::finalise *args, &action
  end

  def sum( *args, &action )
    Hornetseye::sum *args, &action
  end

  def setup
  end

  def teardown
  end

  def test_unary
    assert_equal S(W)[-1, -2, -3], -S(W)[1, 2, 3]
    assert_equal S(W)[-1, -2, -3], -S(W)[1, 2, 3]
    assert !lazy { -S(W)[1, 2, 3] }.finalised?
  end

  def test_binary
    assert_equal S(W)[2, 3, 4], S(W)[1, 2, 3] + 1
    assert_equal S(W)[2, 3, 4], S(W)[1, 2, 3] + 1
    assert !lazy { S(W)[1, 2, 3] + 1 }.finalised?
    assert_equal S(W)[257, 258, 259], S(W)[1, 2, 3] + 256
    assert_equal S(W)[2, 4, 6], S(W)[1, 2, 3] + S(W)[1, 2, 3]
  end

end

