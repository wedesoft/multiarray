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

  class FLOAT_ < Element

    class << self

      attr_accessor :double

      def memory
        Malloc
      end

      def storage_size
        double ? 8 : 4
      end

      def default
        0.0
      end

      def coercion( other )
        if other < FLOAT_
          Hornetseye::FLOAT( ( double or other.double ) )
        elsif other < INT_
          self
        else
          super other
        end
      end

      def directive
        double ? 'd' : 'f'
      end

      def inspect
        "#{ double ? 'D' : 'S' }FLOAT"
      end

      def descriptor( hash )
        "#{ double ? 'D' : 'S' }FLOAT"
      end

      def ==( other )
        other.is_a? Class and other < FLOAT_ and double == other.double
      end

      def hash
        [ :FLOAT_, double ].hash
      end

      def eql?( other )
        self == other
      end

    end

  end

  module Match

    def fit( *values )
      if values.all? { |value| value.is_a? Float or value.is_a? Integer }
        if values.any? { |value| value.is_a? Float }
          DFLOAT
        else
          super *values
        end
      else
        super *values
      end
    end

  end

  Node.extend Match

  SINGLE = false
  DOUBLE = true

  def FLOAT( double )
    retval = Class.new FLOAT_
    retval.double = double
    retval
  end

  module_function :FLOAT

  SFLOAT = FLOAT SINGLE
  DFLOAT = FLOAT DOUBLE

  def SFLOAT( value )
    SFLOAT.new value
  end

  module_function :SFLOAT

  def DFLOAT( value )
    DFLOAT.new value
  end

  module_function :DFLOAT

end
