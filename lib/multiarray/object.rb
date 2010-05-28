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

  class OBJECT < Element

    class << self

      def inspect
        'OBJECT'
      end

      def descriptor( hash )
        'OBJECT'
      end

      def memory
        List
      end

      def storage_size
        1
      end

      def default
        nil
      end

      def coercion( other )
        if other < Sequence_
          other.coercion self
        else
          self
        end
      end

      def coerce( other )
        return self, self
      end

      def compilable?
        false
      end

    end

    module Match

      def fit( *values )
        OBJECT
      end

    end

    Node.extend Match

  end

end
