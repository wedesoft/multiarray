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

  # Class for representing masking operations
  class Mask < Node

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
    # @param [Node] source Source array with values to apply mask to.
    # @param [Node] m Boolean array with values of mask.
    # @param [Node] index Counter for maintaining size of result.
    #
    # @private
    def initialize( dest, source, m, index )
      @dest, @source, @m, @index = dest, source, m, index
    end

    def sexp?
      true
    end

    # Get unique descriptor of this object
    #
    # @param [Hash] hash Labels for any variables.
    #
    # @return [String] Descriptor of this object,
    #
    # @private
    def descriptor( hash )
      "Mask(#{@dest.descriptor( hash )},#{@source.descriptor( hash )}," +
        "#{@m.descriptor( hash )},#{@index.descriptor( hash )})"
    end

    def typecode
      @dest.typecode
    end

    def shape
      @dest.shape
    end

    # Perform masking operation
    #
    # @return [Node] Result of computation
    #
    # @private
    def demand
      if variables.empty?
        index = @index.simplify
        if @m.dimension > 0
          @m.shape.last.times do |i|
            m = @m.element INT.new( i )
            source = @source.element INT.new( i )
            Mask.new( @dest, source, m, index ).demand
          end  
        else
          @m.if do
            Store.new( @dest.element( index ), @source ).demand
            index.assign index + 1
          end
        end
        if @index.is_a? Pointer_
          @index.store index
        else
          @index.assign index
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
      self.class.new @dest.subst( hash ), @source.subst( hash ), @m.subst( hash ),
                     @index.subst( hash )
    end

    # Get variables contained in this term
    #
    # @return [Set] Returns list of variables.
    #
    # @private
    def variables
      @dest.variables + @source.variables + @m.variables + @index.variables
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
      stripped = [ @dest, @source, @m, @index ].collect { |value| value.strip }
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
      [ @dest, @source, @m, @index ].all? { |value| value.compilable? }
    end

  end

end

