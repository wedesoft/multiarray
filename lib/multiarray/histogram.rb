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

  # Class for representing histogram computations
  class Histogram < Node

    class << self

      # Check whether objects of this class are finalised computations
      #
      # @return [Boolean] Returns +false+.
      #
      # @private
      def finalised?
        false
      end

    end

    # Constructor
    #
    # @param [Node] dest Target array to write histogram to.
    # @param [Node] weight The weight(s) for the histogram elements.
    # @param [Array<Node>] sources Arrays with elements to compute histogram of.
    #
    # @private
    def initialize( dest, weight, *sources )
      @dest, @weight, @sources = dest, weight, sources
    end

    # Get unique descriptor of this object
    #
    # @param [Hash] hash Labels for any variables.
    #
    # @return [String] Descriptor of this object,
    #
    # @private
    def descriptor( hash )
      "Histogram(#{@dest.descriptor( hash )}," +
        "#{@weight.descriptor( hash )}," +
        "#{@sources.collect { |source| source.descriptor( hash ) }.join ','})"
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
        if @sources.any? { |source| source.dimension > 0 }
          source_type = @sources.inject { |a,b| a.dimension > b.dimension ? a : b }
          source_type.shape.last.times do |i|
            sources = @sources.collect do |source|
              source.dimension > 0 ? source.element(INT.new(i)) : source
            end
            weight = @weight.dimension > 0 ? @weight.element(INT.new(i)) : @weight
            Histogram.new(@dest, weight, *sources).demand
          end
        else
          dest = @dest
          (@dest.dimension - 1).downto(0) do |i|
            dest = dest.element @sources[i].demand
          end
          dest.store dest + @weight
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
      self.class.new @dest.subst( hash ), @weight.subst( hash ),
                     *@sources.collect { |source| source.subst hash }
    end

    # Get variables contained in this term
    #
    # @return [Set] Returns list of variables.
    #
    # @private
    def variables
      @sources.inject(@dest.variables + @weight.variables) { |a,b| a + b.variables }
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
      stripped = ( [ @dest, @weight ] + @sources ).collect { |source| source.strip }
      return stripped.inject([]) { |vars,elem| vars + elem[0] },
           stripped.inject([]) { |values,elem| values + elem[1] },
           self.class.new( *stripped.collect { |elem| elem[2] } )
    end

    # Check whether this term is compilable
    #
    # @return [Boolean] Returns whether this term is compilable.
    #
    # @private
    def compilable?
      @dest.compilable? and @weight.compilable? and
        @sources.all? { |source| source.compilable? }
    end

  end

end

