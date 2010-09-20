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

  class Store < Node

    def initialize( dest, source )
      @dest, @source = dest, source
    end

    def descriptor( hash )
      "Store(#{@dest.descriptor( hash )},#{@source.descriptor( hash )})"
    end

    def array_type
      @dest.array_type
    end

    def demand
      if variables.empty?
        if dimension > 0
          shape.last.times do |i|
            dest = @dest.element( INT.new( i ) )
            source = @source.dimension == 0 ? @source : @source.element( INT.new( i ) )
            Store.new( dest, source ).demand
          end  
        else
          @dest.store @source.demand
        end
        @dest
      else
        super
      end
    end

    def subst( hash )
      self.class.new @dest.subst( hash ), @source.subst( hash )
    end

    def variables
      @dest.variables + @source.variables
    end

    def strip
      vars1, values1, term1 = @dest.strip
      vars2, values2, term2 = @source.strip
      return vars1 + vars2, values1 + values2, Store.new( term1, term2 )
    end
  
    def compilable?
      @dest.compilable? and @source.compilable?
    end

  end

end

