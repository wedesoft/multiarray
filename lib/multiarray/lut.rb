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

  class Lut < Node

    class << self

      def finalised?
        false
      end

    end

    def initialize( source, table, n )
      @source, @table = source, table
      @n = n || @source.shape.first
    end

    def descriptor( hash )
      "Lut(#{@source.descriptor( hash )},#{@table.descriptor( hash )},#{@n})"
    end

    def array_type
      shape = @table.shape.first( @table.dimension - @n ) + @source.shape[ 1 .. -1 ]
      Hornetseye::MultiArray @table.typecode, *shape
    end

    def demand
      @source.lut @table, :n => @n, :safe => false
    end

    def subst( hash )
      self.class.new @source.subst( hash ), @table.subst( hash ), @n
    end

    def variables
      @source.variables + @table.variables
    end

    def strip
      vars1, values1, term1 = @source.strip
      vars2, values2, term2 = @table.strip
      return vars1 + vars2, values1 + values2, self.class.new( term1, term2, @n )
    end

    def skip( index, start )
      self.class.new @source.skip( index, start ), @table.skip( index, start ), @n
    end

    def element( i )
      source, table = @source, @table
      if source.dimension > 1
        source = source.element i
        self.class.new source, table, @n
      elsif table.dimension > @n
        @n.times { table = table.unroll }
        table = table.element i
        self.class.new source, table, @n
      else
        super i
      end
    end

    def slice( start, length )
      raise 'not implemented yet'
    end

    def compilable?
      @source.compilable? and @table.compilable?
    end

  end

end

