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

  class Variable < Node

    attr_reader :meta

    def initialize( meta )
      @meta = meta
    end

    def inspect
      "Variable(#{@meta.inspect})"
    end

    def descriptor( hash )
      if hash[ self ]
        "Variable#{hash[ self ]}(#{@meta.descriptor( hash )})"
      else
        "Variable(#{@meta.descriptor( hash )})"
      end
    end

    def size
      @meta.size
    end

    def size=( value )
      @meta.size = value
    end

    def array_type
      @meta.array_type
    end

    def strip
      meta_vars, meta_values, meta_term = @meta.strip
      if meta_vars.empty?
        return [], [], self
      else
        return meta_vars, meta_values, Variable.new( meta_term )
      end
    end

    def subst( hash )
      if hash[ self ]
        hash[ self ]
      elsif not @meta.variables.empty? and hash[ @meta.variables.to_a.first ]
        Variable.new @meta.subst( hash )
      else
        self
      end
    end

    def variables
      Set[ self ]
    end

    def lookup( value, stride )
      Lookup.new self, value, stride
    end

  end

end
