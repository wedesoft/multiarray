# multiarray - Lazy multi-dimensional arrays for Ruby
# Copyright (C) 2010, 2011 Jan Wedekind
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

  class Argument < Node
    
    class << self
  
      def finalised?
        false
      end
  
    end
  
    def initialize(value, index, block, var1, var2, zero)
      @value, @index, @block, @var1, @var2, @zero = value, index, block, var1, var2, zero
    end
  
    def descriptor(hash)
      hash = hash.merge @index => ((hash.values.max || 0) + 1)
      hash = hash.merge @var1 => ((hash.values.max || 0) + 1)
      hash = hash.merge @var2 => ((hash.values.max || 0) + 1)
      "Argument(#{@value.descriptor(hash)},#{@index.descriptor(hash)}," +
        "#{@block.descriptor(hash)},#{@zero.descriptor(hash)})"
    end
  
    def typecode
      INT
    end
  
    def shape
      @value.shape
    end
  
    def demand
      initial = @value.subst(@index => INT.new(0)).simplify
      retval = @zero.simplify
      INT.new(0).upto @index.size - 1 do |i|
        sub = @value.subst @index => INT.new(i)
        cond = @block.subst @var1 => sub, @var2 => initial
        retval.assign cond.conditional(INT.new(i), retval)
        initial.assign cond.conditional(sub, initial)
      end
      retval
    end
  
    def element(i)
      self.class.new @value.element(i), @index, @block, @var1, @var2, @zero
    end
  
    def variables
      @value.variables + @zero.variables - @index.variables
    end
  
    def strip
      meta_vars, meta_values, var = @index.strip
      vars, values, term = @value.subst(@index => var).strip
      block_vars, block_values, block_term = @block.strip
      zero_vars, zero_values, zero_term = @zero.strip
      return vars + meta_vars + block_vars + zero_vars,
        values + meta_values + block_values + zero_values,
        self.class.new(term, var, block_term, @var1, @var2, zero_term)
    end
  
    def subst(hash)
      subst_var = @index.subst hash
      value = @value.subst(@index => subst_var).subst hash
      block = @block.subst hash
      zero = @zero.subst hash
      self.class.new value, subst_var, block, @var1, @var2, zero
    end
  
    def compilable?
      @value.compilable? and @block.compilable? and @zero.compilable?
    end
  
  end

end
  
