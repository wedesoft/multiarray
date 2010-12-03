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
    # @param [Array<Node>] sources Arrays with elements to compute histogram of.
    #
    # @private
    def initialize( dest, *sources )
      @dest, @sources = dest, sources
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
        "#{@sources.collect { |source| source.descriptor( hash ) }.join ','})"
    end

    # Get type of result of delayed operation
    #
    # @return [Class] Type of result.
    #
    # @private
    def array_type
      retval = @dest.array_type
      ( class << self; self; end ).instance_eval do
        define_method( :array_type ) { retval }
      end
      retval
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
          source_type = @sources.collect { |source| source.array_type }.
            inject { |a,b| a.coercion b }
          source_type.shape.last.times do |i|
            sources = @sources.collect do |source|
              source.dimension > 0 ? source.element( INT.new( i ) ) : source
            end
            Histogram.new( @dest, *sources ).demand
          end
        else
          dest = @dest
          ( @dest.dimension - 1 ).downto( 0 ) do |i|
            dest = dest.element @sources[ i ].demand
          end
          dest.store dest + 1
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
      self.class.new @dest.subst( hash ), @source.subst( hash )
    end

    # Get variables contained in this term
    #
    # @return [Set] Returns list of variables.
    #
    # @private
    def variables
      @sources.inject( @dest.variables ) { |a,b| a + b.variables }
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
      vars2, values2, term2 = @source.strip
      return vars1 + vars2, values1 + values2, self.class.new( term1, term2 )
    end

    # Check whether this term is compilable
    #
    # @return [Boolean] Returns whether this term is compilable.
    #
    # @private
    def compilable?
      @dest.compilable? and @source.compilable?
    end

  end

end

