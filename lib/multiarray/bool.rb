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

  class BOOL < Element

    class << self

      def compilable?
        false
      end

      def fetch( ptr )
        new ptr.load( self ) != 0
      end

      def memory
        Malloc
      end

      def storage_size
        1
      end

      def default
        false
      end

      def directive
        'c'
      end

      def inspect
        'BOOL'
      end

      def descriptor( hash )
        'BOOL'
      end

    end

    def write( ptr )
      ptr.save UBYTE.new( get.conditional( 1, 0 ) )
    end

    module Match

      def fit( *values )
        if values.all? { |value| [ false, true ].member? value }
          BOOL
        else
          super *values
        end
      end

    end

    Node.extend Match

  end

end
