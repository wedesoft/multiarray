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

  class Lookup < Node

    def initialize( p, index, stride )
      @p, @index, @stride = p, index, stride
    end

    def descriptor( hash )
      "Lookup(#{@p.descriptor( hash )},#{@index.descriptor( hash )},#{@stride.descriptor( hash )})"
    end

    def array_type
      @p.array_type
    end

    def subst( hash )
      @p.subst( hash ).lookup @index.subst( hash ), @stride.subst( hash )
    end

    def variables
      @p.variables + @index.variables + @stride.variables
    end

    def strip
      vars1, values1, term1 = @p.strip
      vars2, values2, term2 = @stride.strip
      return vars1 + vars2, values1 + values2,
        Lookup.new( term1, @index, term2 )
    end

    def lookup( value, stride )
      if value.is_a? Variable
        Lookup.new self, value, stride
      else
        Lookup.new @p.lookup( value, stride ), @index, @stride
      end
    end

    def element( i )
      Lookup.new @p.element( i ), @index, @stride
    end

  end

end
