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

  class INDEX_ < Element

    class << self

      # Size of range for this index
      #
      # @return [Object] Size of range for this index.
      attr_accessor :size

      def inspect
        "INDEX(#{size.inspect})"
      end

      # Get unique descriptor of this class
      #
      # @param [Hash] hash Labels for any variables.
      #
      # @return [String] Descriptor of this class.
      #
      # @private
      def descriptor( hash )
        "INDEX(#{size.descriptor( hash )})"
      end

      def array_type
        INT
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
        meta_vars, meta_values = size.strip
        if meta_vars.empty?
          return [], [], self
        else
          return meta_vars, meta_values, Hornetseye::INDEX( meta_vars.first )
        end
      end

      def subst( hash )
        Hornetseye::INDEX size.subst( hash )
      end

      def variables
        size.variables
      end

    end

    def initialize
      raise "#{self.class.inspect} must not be instantiated"
    end

  end

  def INDEX( size )
    retval = Class.new INDEX_
    size = INT.new( size ) unless size.is_a? Node
    retval.size = size
    retval
  end

  module_function :INDEX

end
