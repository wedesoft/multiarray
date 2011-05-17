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

  # Class for representing connected component analysis
  class Components < Node

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
    # @param [Node] dest Target array to write component labels to.
    # @param [Node] source Array to extract components from.
    # @param [Node] default Value of background pixel.
    # @param [Node] zero Zero is used to aid compilation.
    # @param [Node] labels Array to store label correspondences.
    # @param [Node] rank Array to store number of indirections for each label.
    # @param [Node] n Pointer to return number of components.
    def initialize( dest, source, default, zero, labels, rank, n )
      @dest, @source, @default, @zero, @labels, @rank, @n =
        dest, source, default, zero, labels, rank, n
    end

    # Get unique descriptor of this object
    #
    # @param [Hash] hash Labels for any variables.
    #
    # @return [String] Descriptor of this object,
    #
    # @private
    def descriptor( hash )
      "Components(#{@dest.descriptor( hash )},#{@source.descriptor( hash )}," +
        "#{@default.descriptor( hash )},#{@zero.descriptor( hash )}," +
        "#{@labels.descriptor( hash )},#{@rank.descriptor( hash )}," +
        "#{@n.descriptor( hash )})"
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
      knot [], []
      @dest
    end

    # Recursive function to perform connected component labeling
    #
    # @param [Array<Proc>] args Array with functions for locating neighbouring elements.
    # @param [Array<Proc>] comp Array with functions for locating neighbouring labels.
    #
    # @private
    def knot( args, comp )
      n = @n.simplify
      if dimension > 0
        subargs1, subargs2, subargs3 = [], [], []
        subcomp1, subcomp2, subcomp3 = [], [], []
        args.each do |arg|
          subargs1.push proc { |i| arg.element( i - 1 ).demand }
          subargs2.push proc { |i| arg.element( i     ).demand }
          subargs3.push proc { |i| arg.element( i + 1 ).demand }
        end
        comp.each do |c|
          subcomp1.push proc { |i| c.element( i - 1 ) }
          subcomp2.push proc { |i| c.element( i     ) }
          subcomp3.push proc { |i| c.element( i + 1 ) }
        end
        self.class.new( @dest.element( INT.new( 0 ) ),
                        @source.element( INT.new( 0 ) ).demand, @default, @zero,
                        @labels, @rank, n ).
          knot( ( subargs2 + subargs3 ).collect { |p| p.call INT.new( 0 ) },
                ( subcomp2 + subcomp3 ).collect { |p| p.call INT.new( 0 ) } )
        INT.new( 1 ).upto INT.new( @source.shape.last ) - 2 do |i|
          self.class.new( @dest.element( INT.new( i ) ),
                          @source.element( INT.new( i ) ).demand, @default, @zero,
                          @labels, @rank, n ).
            knot( ( subargs1 + subargs2 + subargs3 ).collect { |p| p.call INT.new( i ) } +
                  [ @source.element( INT.new( i ) - 1 ) ],
                  ( subcomp1 + subcomp2 + subcomp3 ).collect { |p| p.call INT.new( i ) } +
                  [ @dest.element( INT.new( i ) - 1 ) ] )
        end
        i = @source.shape.last - 1
        self.class.new( @dest.element( INT.new( i ) ),
                        @source.element( INT.new( i ) ).demand, @default, @zero,
                        @labels, @rank, n ).
          knot( ( subargs1 + subargs2 ).collect { |p| p.call INT.new( i ) } +
                [ @source.element( INT.new( i ) - 1 ) ],
                ( subcomp1 + subcomp2 ).collect { |p| p.call INT.new( i ) } +
                [ @dest.element( INT.new( i ) - 1 ) ] )
      else
        @source.ne( @default ).if_else( proc do
          label = @zero.simplify
          args.zip( comp ).each do |arg,other|
            @source.eq( arg ).if do
              other = other.simplify
              proc { other.ne( @labels.element( other ).demand ) }.while do
                other.assign @labels.element( other ).demand
              end
              label.eq( @zero ).if_else( proc do
                label.assign other
              end, proc do
                label.ne( other ).if do
                  ( @rank.element( label ).demand <= @rank.element( other ).demand ).if_else( proc do
                    @labels[ other ] = label
                    @rank.element( label ).demand.eq( @rank.element( other ).demand ).if do
                      @rank[ label ] = @rank.element( other ).demand + 1
                    end
                  end, proc do
                    @labels[ label ] = other
                    label.assign other
                  end )
                end
              end )
            end
          end
          label.eq( @zero ).if do
            n.assign n + 1
            @labels[ n ] = n
            @rank[ n ] = 0
            label.assign n
          end
          @dest.store label
        end, proc do
          @dest.store INT.new( 0 )
        end )
      end
      if @n.is_a? Pointer_
        INT.new( 0 ).upto n do |i|
          l = UINT.new( i ).simplify
          proc { l.ne( @labels.element( l ).demand ) }.while do
            l.assign @labels.element( l ).demand
          end
          @labels[ INT.new( i ) ] = l
        end
        @n.store n
      else
        @n.assign n
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
      self.class.new @dest.subst( hash ), @source.subst( hash ), @default.subst( hash ),
        @zero.subst( hash ), @labels.subst( hash ), @rank.subst( hash ), @n.subst( hash )
    end

    # Get variables contained in this term
    #
    # @return [Set] Returns list of variables.
    #
    # @private
    def variables
      @dest.variables + @source.variables + @default.variables + @zero.variables +
        @labels.variables + @rank.variables + @n.variables
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
      stripped = [ @dest, @source, @default, @zero, @labels, @rank, @n ].
        collect { |value| value.strip }
      return stripped.inject( [] ) { |vars,elem| vars + elem[ 0 ] },
        stripped.inject( [] ) { |values,elem| values + elem[ 1 ] },
        self.class.new( *stripped.collect { |elem| elem[ 2 ] } )
    end

    # Get variables contained in this term
    #
    # @return [Set] Returns list of variables.
    #
    # @private
    def compilable?
      [ @dest, @source, @default, @zero, @labels, @rank, @n ].all? do |value|
        value.compilable?
      end
    end

  end

end

