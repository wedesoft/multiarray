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

module Hornetseye

  # Class for generating random number arrays
  class Random < Node

    # Constructor
    #
    # @param [Node] dest Target array to write array to.
    # @param [Node] n Upper boundary for random value.
    #
    # @private
    def initialize( dest, n )
      @dest, @n = dest, n
    end

    # Get unique descriptor of this object
    #
    # @param [Hash] hash Labels for any variables.
    #
    # @return [String] Descriptor of this object,
    #
    # @private
    def descriptor( hash )
      "Random(#{@dest.descriptor( hash )},#{@n.descriptor( hash )})"
    end

    def typecode
      @dest.typecode
    end

    def shape
      @dest.shape
    end

    # Reevaluate computation
    #
    # @return [Node,Object] Result of computation
    #
    # @see #force
    #
    # @private
    def demand
      if variables.empty?
        if dimension > 0
          shape.last.times do |i|
            dest = @dest.element INT.new( i )
            Random.new( dest, @n ).demand
          end  
        else
          if @n.typecode < INT_ or ( @n.typecode < OBJECT and @n.get.is_a? Integer )
            @dest.store @n.typecode.new( @n.get.lrand )
          else
            @dest.store @n.typecode.new( @n.get.drand )
          end
        end
        @dest
      else
        super
      end
    end

    # Substitute variables
    #
    # Substitute the variables with the values given in the hash.
    #
    # @param [Hash] hash Substitutions to apply.
    #
    # @return [Node] Term with substitutions applied.
    #
    # @private
    def subst( hash )
      self.class.new @dest.subst( hash ), @n.subst( hash )
    end

    # Get variables contained in this term
    #
    # @return [Set] Returns list of variables.
    #
    # @private
    def variables
      @dest.variables + @n.variables
    end

    # Strip of all values
    #
    # Split up into variables, values, and a term where all values have been
    # replaced with variables.
    #
    # @return [Array<Array,Node>] Returns an array of variables, an array of
    # values, and the term based on variables.
    #
    # @private
    def strip
      vars1, values1, term1 = @dest.strip
      vars2, values2, term2 = @n.strip
      return vars1 + vars2, values1 + values2, Random.new( term1, term2 )
    end
  
    # Check whether this term is compilable
    #
    # @return [Boolean] Returns whether this term is compilable.
    #
    # @private
    def compilable?
      @dest.compilable? and @n.compilable?
    end

  end

end

