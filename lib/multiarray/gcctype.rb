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
      when SFLOAT
        'float'
      when DFLOAT
        'double'
      else
        if @typecode < Pointer_
          'unsigned char *'
        elsif @typecode < INDEX_
          'int'
        else
          raise "No identifier available for #{@typecode.inspect}"
        end
      end
    end

    def identifiers
      if @typecode < Composite
        GCCType.new( @typecode.element_type ).identifiers * @typecode.num_elements
      else
        [ GCCType.new( @typecode ).identifier ]
      end
    end

    def r2c
      case @typecode
      when BOOL
        [ lambda { |expr| "( #{expr} ) != Qfalse" } ]
      when BYTE, UBYTE, SINT, USINT, INT, UINT
        [ lambda { |expr| "NUM2INT( #{expr} )" } ]
      when SFLOAT, DFLOAT
        [ lambda { |expr| "NUM2DBL( #{expr} )" } ]
      else
        if @typecode < Pointer_
          [ lambda { |expr| "(#{identifier})mallocToPtr( #{expr} )" } ]
        elsif @typecode < Composite
          GCCType.new( @typecode.element_type ).r2c * @typecode.num_elements
        else
          raise "No conversion available for #{@typecode.inspect}"
        end
      end
    end

  end

end
 
