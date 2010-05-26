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

  class INDEX_ < Element

    class << self

      attr_accessor :size

      def inspect
        "INDEX(#{size.inspect})"
      end

      def descriptor( hash )
        "INDEX(#{size.descriptor( hash )})"
      end

      def array_type
        INT
      end

      def strip
        var = Variable.new INT
        return [ var ], [ size ], INDEX( var )
      end

      def subst( hash )
        INDEX size.subst( hash )
      end

      def variables
        size.variables
      end

    end

    def initialize
      raise "#{self.class.inspect} must not be instantiated"
    end

  end

  def INDEX( size )
    retval = Class.new INDEX_
    size = INT.new( size ) unless size.is_a? Node
    retval.size = size
    retval
  end

  module_function :INDEX

end
