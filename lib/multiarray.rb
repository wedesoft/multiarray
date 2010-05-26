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

# Proc#bind is defined if it does not exist already
class Proc

  unless method_defined? :bind

    # Proc#bind is defined if it does not exist already
    #
    # @private
    def bind( object )
      block, time = self, Time.now
      ( class << object; self end ).class_eval do
        method_name = "__bind_#{time.to_i}_#{time.usec}"
        define_method method_name, &block
        method = instance_method method_name
        remove_method method_name
        method
      end.bind object
    end

  end

end

class TrueClass

  def not
     false
  end

  def and( other )
    if [ false, true ].member? other
      other
    else
      x, y = other.coerce self
      x.and y
    end
  end

  def or( other )
    if [ false, true ].member? other
      true
    else
      x, y = other.coerce self
      x.or y
    end
  end

  def conditional( a, b )
    a
  end

end

class FalseClass

  def not
    true
  end

  def and( other )
    if [ false, true ].member? other
      false
    else
      x, y = other.coerce self
      x.and y
    end
  end

  def or( other )
    if [ false, true ].member? other
      other
    else
      x, y = other.coerce self
      x.or y
    end
  end

  def conditional( a, b )
    b
  end

end

# Object#instance_exec is defined if it does not exist already
class Object

  unless method_defined? :instance_exec

    # Object#instance_exec is defined if it does not exist already
    #
    # @private
    def instance_exec( *arguments, &block )
      block.bind( self )[ *arguments ]
    end

  end

  def eq( other )
    unless other.is_a? Hornetseye::Node
      self == other
    else
      x, y = other.coerce self
      x.eq y
    end
  end

  def ne( other )
    unless other.is_a? Hornetseye::Node
      ( self == other ).not
    else
      x, y = other.coerce self
      x.ne y
    end
  end

end

# Range#min and Range#max are replaced for performance reasons
class Range

  public

  alias_method :orig_min, :min

  alias_method :orig_max, :max

  # For performance reasons a specialised method for integers is added
  def min
    if self.begin.is_a? Integer
      self.begin
    else
      orig_min
    end
  end

  # For performance reasons a specialised method for integers is added.
  def max
    if self.end.is_a? Integer
      exclude_end? ? self.end - 1 : self.end
    else
      orig_max
    end
  end

  # Compute the size of a range.
  def size
    max + 1 - min
  end

end

# Module#alias_method_chain is defined.
#
# @private
class Module

  unless method_defined? :alias_method_chain

    # Method for creating alias chains.
    #
    # @private
    def alias_method_chain( target, feature, vocalize = target )
      alias_method "#{vocalize}_without_#{feature}", target
      alias_method target, "#{vocalize}_with_#{feature}"
    end

  end

end

require 'malloc'
require 'set'
require 'tmpdir'
require 'multiarray/malloc'
require 'multiarray/list'
require 'multiarray/node'
require 'multiarray/element'
require 'multiarray/object'
require 'multiarray/index'
require 'multiarray/bool'
require 'multiarray/int'
require 'multiarray/pointer'
require 'multiarray/variable'
require 'multiarray/lambda'
require 'multiarray/lookup'
require 'multiarray/unary'
require 'multiarray/binary'
require 'multiarray/operations'
require 'multiarray/inject'
require 'multiarray/diagonal'
require 'multiarray/sequence'
require 'multiarray/multiarray'
require 'multiarray/gcctype'
require 'multiarray/gccvalue'
require 'multiarray/gcccontext'
require 'multiarray/gcccache'
require 'multiarray/gccfunction'

module Hornetseye

  def lazy( *shape, &action )
    previous = Thread.current[ :lazy ]
    Thread.current[ :lazy ] = true
    begin
      options = shape.last.is_a?( Hash ) ? shape.pop : {}
      arity = options[ :arity ] || action.arity
      if arity <= 0
        action.call
      else
        index = Variable.new shape.empty? ? Hornetseye::INDEX( nil ) :
                                            Hornetseye::INDEX( shape.pop )
        term = lazy *( shape + [ :arity => arity - 1 ] ) do |*args|
          action.call *( args + [ index ] )
        end
        term = Node.match( term ).new term unless term.is_a? Node
        Lambda.new index, term
      end
    ensure
      Thread.current[ :lazy ] = previous
    end
  end

  module_function :lazy

  def eager( *shape, &action )
    previous = Thread.current[ :lazy ]
    Thread.current[ :lazy ] = false
    begin
      retval = lazy *shape, &action
      retval.is_a?( Node ) ? retval.force : retval
    ensure
      Thread.current[ :lazy ] = previous
    end
  end

  module_function :eager

  def sum( *shape, &action )
    options = shape.last.is_a?( Hash ) ? shape.pop : {}
    arity = options[ :arity ] || action.arity
    if arity <= 0
      action.call
    else
      index = Variable.new shape.empty? ? Hornetseye::INDEX( nil ) :
                           Hornetseye::INDEX( shape.pop )
      term = sum *( shape + [ :arity => arity - 1 ] ) do |*args|
        action.call *( args + [ index ] )
      end
      var1 = Variable.new term.typecode
      var2 = Variable.new term.typecode
      Inject.new( term, index, nil, var1 + var2, var1, var2 ).force.get
    end
  end

  module_function :sum

end
