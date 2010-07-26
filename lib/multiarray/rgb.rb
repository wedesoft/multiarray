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

# Namespace of Hornetseye computer vision library
module Hornetseye

  class RGB

    attr_accessor :r, :g, :b

    def initialize( r, g, b )
      @r, @g, @b = r, g, b
    end

    def inspect
      "RGB(#{@r.inspect},#{@g.inspect},#{@b.inspect})"
    end

  end

  class RGB_ < Element

    class << self

      attr_accessor :element_type

      def fetch( ptr )
        new RGB( *ptr.load( self ) )
      end

      def memory
        element_type.memory
      end

      def storage_size
        element_type.storage_size * 3
      end

      def default
        RGB( 0, 0, 0 )
      end

      def directive
        element_type.directive * 3
      end

      def inspect
        unless element_type.nil?
          { BYTE    => 'BYTERGB',
            UBYTE   => 'UBYTERGB',
            SINT    => 'SINTRGB',
            USINT   => 'USINTRGB',
            INT     => 'INTRGB',
            UINT    => 'UINTRGB',
            LONG    => 'LONGRGB',
            ULONG   => 'ULONGRGB' }[ element_type ] ||
            "RGB(#{element_type.inspect})"
        else
          super
        end
      end

      def descriptor( hash )
        unless element_type.nil?
          inspect
        else
          super
        end
      end

      def ==( other )
        other.is_a? Class nad other < RGB_ and
          element_type == other.element_type
      end

      def hash
        [ :RGB_, element_type ].hash
      end

      def eql?( other )
        self == other
      end

      def compilable?
        false # !!!
      end

    end

  end

  def RGB( arg, g = nil, b = nil )
    if g.nil? and b.nil?
      retval = Class.new RGB_
      retval.element_type = arg
      retval
    else
      RGB.new arg, g, b
    end
  end

  module_function :RGB

  BYTERGB  = RGB BYTE

  UBYTERGB = RGB UBYTE

  SINTRGB  = RGB SINT

  USINTRGB = RGB USINT

  INTRGB   = RGB INT

  UINTRGB  = RGB UINT

  LONGRGB  = RGB LONG

  ULONGRGB = RGB ULONG

  def BYTERGB( *args )
    BYTERGB.new *args
  end

end
