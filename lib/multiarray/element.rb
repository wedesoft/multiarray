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

  class Element < Node

    class << self

      def fetch( ptr )
        new ptr.load( self )
      end

      def coercion( other )
        if self == other
          self
        else
          x, y = other.coerce self
          x.coercion y
        end
      end

    end

    def initialize( value = self.class.default )
      @value = value
    end

    def descriptor( hash )
      "#{self.class.to_s}(#{@value.to_s})"
    end

    def demand
      if @value.respond_to? :demand
        self.class.new @value.demand( self.class )
      else
        self.class.new @value
      end
    end

    def strip
      variable = Variable.new self.class
      return [ variable ], [ self ], variable
    end

    def compilable?
      if @value.respond_to? :compilable?
        @value.compilable?
      else
        super
      end
    end

    def get
      @value
    end

    def store( value )
      if @value.respond_to? :store
        @value.store value.demand.get
      else
        @value = value.demand.get
      end
    end

    def write( ptr )
      ptr.save self
    end

  end

end
