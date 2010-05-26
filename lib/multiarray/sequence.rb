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

  class Sequence

    class << self

      def new( typecode, size )
        MultiArray.new typecode, size
      end

      def []( *args )
        target = Node.fit args
        target = Hornetseye::Sequence OBJECT, args.size if target.dimension > 1
        retval = target.new
        args.each_with_index { |arg,i| retval[ i ] = arg }
        retval
      end

    end

  end

  class Sequence_

    class << self

      attr_accessor :element_type
      attr_accessor :num_elements

      def default
        Hornetseye::lazy( num_elements ) { |i| element_type.default }
      end

      def indgen( offset = 0, increment = 1 )
        Hornetseye::lazy( num_elements ) do |i|
          if offset == 0
            if increment == 1
              i
            else
              increment * i
            end
          else
            if increment == 1
              offset + i
            else
              offset + increment * i
            end
          end
        end
      end

      def shape
        element_type.shape + [ num_elements ]
      end

      def typecode
        element_type.typecode
      end

      def array_type
        self
      end

      def pointer_type
        self
      end

      def dimension
        element_type.dimension + 1
      end

      def contiguous
        self
      end

      def bool
        Hornetseye::Sequence element_type.bool, num_elements
      end

      def bool_binary( other )
        coercion( other ).bool
      end

      def inspect
        if dimension == 1
          "Sequence(#{typecode.inspect},#{num_elements.inspect})"
        else
          "MultiArray(#{typecode.inspect},#{shape.join ','})"
        end
      end

      def to_s
        descriptor( {} )
      end

      def descriptor( hash )
        if dimension == 1
          "Sequence(#{typecode.descriptor( hash )},#{num_elements.to_s})"
        else
          "MultiArray(#{typecode.descriptor( hash )},#{shape.join ','})"
        end
      end

      def ==( other )
        other.is_a? Class and other < Sequence_ and
          other.element_type == element_type and
          other.num_elements == num_elements
      end

      def coercion( other )
        if other < Sequence_
          Hornetseye::Sequence element_type.coercion( other.element_type ),
                               num_elements
        else
          Hornetseye::Sequence element_type.coercion( other ),
                               num_elements
        end
      end

      def coerce( other )
        if other < Sequence_
          return other, self
        else
          return Hornetseye::Sequence( other, num_elements ), self
        end
      end

      def new
        MultiArray.new typecode, *shape
      end

    end

    module Match

      def fit( *values )
        n = values.inject 0 do |size,value|
          value.is_a?( Array ) ? [ size, value.size ].max : size
        end
        if n > 0
          elements = values.inject [] do |flat,value|
            flat + ( value.is_a?( Array ) ? value : [ value ] )
          end
          Hornetseye::Sequence fit( *elements ), n
        else
          super *values
        end
      end

    end

    Node.extend Match

  end

  def Sequence( element_type, num_elements )
    retval = Class.new Sequence_
    retval.element_type = element_type
    retval.num_elements = num_elements
    retval
  end

  module_function :Sequence

end
