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

module Hornetseye

  class GCCType

    def initialize( typecode )
      @typecode = typecode
    end

    def identifier
      case @typecode
      when nil
        'void'
      when BOOL
        'char'
      when BYTE
        'char'
      when UBYTE
        'unsigned char'
      when SINT
        'short int'
      when USINT
        'unsigned short int'
      when INT
        'int'
      when UINT
        'unsigned int'
      else
        if @typecode < Pointer_
          'void *'
        elsif @typecode < INDEX_
          'int'
        else
          raise "No identifier available for #{@typecode.inspect}"
        end
      end
    end

    def r2c( expr )
      case @typecode
      when BOOL
        "( #{expr} ) != Qfalse"
      when BYTE, UBYTE, SINT, USINT, INT, UINT
        "NUM2INT( #{expr} )"
      else
        if @typecode < Pointer_
          "(#{identifier})mallocToPtr( #{expr} )"
        else
          raise "No conversion available for #{@typecode.inspect}"
        end
      end
    end

  end

end
  
