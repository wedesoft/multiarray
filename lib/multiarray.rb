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

# Module#alias_method_chain is defined.
#
# @private
class Module

  unless method_defined? :alias_method_chain

    # Method for creating alias chains
    #
    # @param [Symbol,String] target Method to rename.
    # @param [Symbol,String] feature Feature to use for renaming.
    # @param [Symbol,String] vocalize Override to use when renaming operators.
    #
    # @return [Module] Returns this module.
    #
    # @private
    def alias_method_chain( target, feature, vocalize = target )
      alias_method "#{vocalize}_without_#{feature}", target
      alias_method target, "#{vocalize}_with_#{feature}"
    end

  end

end

# Proc#bind is defined if it does not exist already
#
# @private
class Proc

  unless method_defined? :bind

    # Proc#bind is defined if it does not exist already
    #
    # @param [Object] object Object to bind this instance of +Proc+ to.
    #
    # @return [Method] The bound method.
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

# +Object+ is extended with a few methods
class Object

  unless method_defined? :instance_exec

    # Object#instance_exec is defined if it does not exist already
    #
    # @param [Array<Object>] arguments The arguments to pass to the block.
    # @param [Proc] block The block to be executed in the object's environment.
    # @return [Object] The result of executing the block.
    # 
    # @private
    def instance_exec( *arguments, &block )
      block.bind( self )[ *arguments ]
    end

  end

  # Boolean negation
  #
  # @return [FalseClass] Returns +false+.
  #
  # @see NilClass#not
  # @see FalseClass#not
  def not
     false
  end

  # Boolean 'and' operation
  #
  # @param [FalseClass,TrueClass,Object] other Other boolean object.
  # @return [FalseClass,TrueClass] Returns +other+.
  #
  # @see FalseClass#and
  # @see NilClass#and
  def and( other )
    unless other.is_a? Hornetseye::Node
      other
    else
      x, y = other.coerce self
      x.and y
    end
  end

  # Boolean 'or' operation
  #
  # @param [FalseClass,TrueClass,Object] other Other boolean object.
  # @return [TrueClass] Returns +true+.
  #
  # @see FalseClass#or
  # @see NilClass#or
  def or( other )
    unless other.is_a? Hornetseye::Node
      self
    else
      x, y = other.coerce self
      x.or y
    end
  end

  # Element-wise equal operator
  #
  # The method calls +self == other+ unless +other+ is of type
  # Hornetseye::Node. In that case an element-wise comparison using
  # Hornetseye::Node#eq is performed after coercion.
  #
  # @return [FalseClass,TrueClass,Hornetseye::Node] Result of comparison.
  # @see Hornetseye::Node
  # @see Hornetseye::Binary_
  def eq( other )
    unless other.is_a? Hornetseye::Node
      self == other
    else
      x, y = other.coerce self
      x.eq y
    end
  end

  # Element-wise not-equal operator
  #
  # The method calls +( self == other ).not+ unless +other+ is of type
  # Hornetseye::Node. In that case an element-wise comparison using
  # Hornetseye::Node#ne is performed after coercion.
  #
  # @return [FalseClass,TrueClass,Hornetseye::Node] Result of comparison.
  # @see Hornetseye::Node
  # @see Hornetseye::Binary_
  def ne( other )
    unless other.is_a? Hornetseye::Node
      ( self == other ).not
    else
      x, y = other.coerce self
      x.ne y
    end
  end

  # Boolean select operation
  #
  # @param [Object] a Object to select if +self+ is neither +false+ nor +nil+.
  # @param [Object] b Object to select if +self+ is +false+ or +nil+.
  # @return [Object] Returns +a+.
  #
  # @see FalseClass#conditional
  # @see NilClass#conditional
  def conditional( a, b )
    a.is_a?( Proc ) ? a.call : a
  end

end

# +NilClass+ is extended with a few methods
class NilClass

  # Boolean negation
  #
  # @return [FalseClass] Returns +false+.
  #
  # @see Object#not
  # @see FalseClass#not
  def not
     true
  end

  # Boolean 'and' operation
  #
  # @param [FalseClass,TrueClass,Object] other Other boolean object.
  # @return [FalseClass] Returns +false+.
  #
  # @see Object#and
  # @see FalseClass#and
  def and( other )
    unless other.is_a? Hornetseye::Node
      self
    else
      x, y = other.coerce self
      x.and y
    end
  end

  # Boolean 'or' operation
  #
  # @param [FalseClass,TrueClass,Object] other Other boolean object.
  # @return [FalseClass,TrueClass] Returns +other+.
  #
  # @see Object#or
  # @see FalseClass#or
  def or( other )
    unless other.is_a? Hornetseye::Node
      other
    else
      x, y = other.coerce self
      x.or y
    end
  end

  # Boolean select operation
  #
  # @param [Object] a Object to select if +self+ is neither +false+ nor +nil+.
  # @param [Object] b Object to select if +self+ is +false+ or +nil+.
  # @return [Object] Returns +b+.
  #
  # @see Object#conditional
  # @see FalseClass#conditional
  def conditional( a, b )
    b.is_a?( Proc ) ? b.call : b
  end

  # Check whether this term is compilable
  #
  # @return [FalseClass,TrueClass] Returns +false+
  #
  # @private
  def compilable?
    false
  end

end

# +FalseClass+ is extended with a few methods
#
# @see TrueClass
class FalseClass

  # Boolean negation
  #
  # @return [FalseClass] Returns +true+.
  #
  # @see Object#not
  # @see NilClass#not
  def not
    true
  end

  # Boolean 'and' operation
  #
  # @param [FalseClass,TrueClass,Object] other Other boolean object.
  # @return [FalseClass] Returns +false+.
  #
  # @see Object#and
  # @see NilClass#and
  def and( other )
    unless other.is_a? Hornetseye::Node
      self
    else
      x, y = other.coerce self
      x.and y
    end
  end

  # Boolean 'or' operation
  #
  # @param [FalseClass,TrueClass,Object] other Other boolean object.
  # @return [FalseClass,TrueClass] Returns +other+.
  #
  # @see Object#or
  # @see NilClass#or
  def or( other )
    unless other.is_a? Hornetseye::Node
      other
    else
      x, y = other.coerce self
      x.or y
    end
  end

  # Boolean select operation
  #
  # @param [Object] a Object to select if +self+ is neither +false+ nor +nil+.
  # @param [Object] b Object to select if +self+ is +false+ or +nil+.
  # @return [Object] Returns +b+.
  #
  # @see Object#conditional
  # @see NilClass#conditional
  def conditional( a, b )
    b.is_a?( Proc ) ? b.call : b
  end

end

# Some methods of +Fixnum+ are modified
#
# @private
class Fixnum

  # +&+ is modified to work with this library
  #
  # @param [Object] other Second operand for binary +and+ operation.
  # @return [Object] Result of binary operation.
  #
  # @private
  def intand_with_hornetseye( other )
    if other.is_a? Integer
      intand_without_hornetseye other
    else
      x, y = other.coerce self
      x & y
    end
  end

  alias_method_chain :&, :hornetseye, :intand

  # +|+ is modified to work with this library
  #
  # @param [Object] other Second operand for binary +or+ operation.
  # @return [Object] Result of binary operation.
  #
  # @private
  def intor_with_hornetseye( other )
    if other.is_a? Integer
      intor_without_hornetseye other
    else
      x, y = other.coerce self
      x | y
    end
  end

  alias_method_chain :|, :hornetseye, :intor

  # +^+ is modified to work with this library
  #
  # @param [Object] other Second operand for binary +xor+ operation.
  # @return [Object] Result of binary operation.
  #
  # @private
  def intxor_with_hornetseye( other )
    if other.is_a? Integer
      intxor_without_hornetseye other
    else
      x, y = other.coerce self
      x ^ y
    end
  end

  alias_method_chain :^, :hornetseye, :intxor

  # +<<+ is modified to work with this library
  #
  # @param [Object] other Second operand for binary +shl+ operation.
  # @return [Object] Result of binary operation.
  #
  # @private
  def shl_with_hornetseye( other )
    if other.is_a? Integer
      shl_without_hornetseye other
    else
      x, y = other.coerce self
      x << y
    end
  end

  alias_method_chain :<<, :hornetseye, :shl

  # +>>+ is modified to work with this library
  #
  # @param [Object] other Second operand for binary +shr+ operation.
  # @return [Object] Result of binary operation.
  #
  # @private
  def shr_with_hornetseye( other )
    if other.is_a? Integer
      shr_without_hornetseye other
    else
      x, y = other.coerce self
      x >> y
    end
  end

  alias_method_chain :>>, :hornetseye, :shr

  if method_defined? :rpower

    # +**+ is modified to work with this library
    #
    # @param [Object] other Second operand for binary operation.
    # @return [Object] Result of binary operation.
    #
    # @private
    def power_with_hornetseye( other )
      if other.is_a? Hornetseye::Node
        x, y = other.coerce self
        x ** y
      else
        power_without_hornetseye other
      end
    end

    alias_method_chain :**, :hornetseye, :power

  end

  # Generate random number
  #
  # Generate a random number greater or equal to zero and lower than this number.
  #
  # @return [Integer] A random number.
  def lrand
    Kernel.rand self
  end

  # Generate random number
  #
  # Generate a random number greater or equal to zero and lower than this number.
  #
  # @return [Float] A random number.
  def drand
    self * Kernel.rand
  end

end

# +Float+ is extend with a few methods
class Float

  # Generate random number
  #
  # Generate a random number greater or equal to zero and lower than this number.
  #
  # @return [Float] A random number.
  def drand
    self * Kernel.rand
  end

end

# +Range+ is extended with a few methods
class Range

  # For performance reasons a specialised method for integers is added
  #
  # @return [Object] Minimum value of range.
  #
  # @private
  def min_with_hornetseye
    if self.begin.is_a? Integer
      self.begin
    else
      min_without_hornetseye
    end
  end

  alias_method_chain :min, :hornetseye

  # For performance reasons a specialised method for integers is added
  #
  # @return [Object] Maximum value of range.
  #
  # @private
  def max_with_hornetseye
    if self.end.is_a? Integer
      exclude_end? ? self.end - 1 : self.end
    else
      max_without_hornetseye
    end
  end

  alias_method_chain :max, :hornetseye

  # Compute the size of a range
  #
  # @return [Integer] Number of discrete values within range.
  def size
    max + 1 - min
  end

end

# The +Numeric+ class is extended with a few methods
class Numeric

  # Compute complex conjugate
  #
  # @return [Numeric] Returns +self+.
  def conj
    self
  end

  # Get red component
  #
  # @return [Numeric] Returns +self+.
  def r
    self
  end

  # Get green component
  #
  # @return [Numeric] Returns +self+.
  def g
    self
  end

  # Get blue component
  #
  # @return [Numeric] Returns +self+.
  def b
    self
  end

  # Get larger number of two numbers
  #
  # @param [Numeric] other The other number.
  #
  # @return [Numeric] The larger number of the two.
  def major( other )
    if other.is_a? Numeric
      ( self >= other ).conditional self, other
    else
      x, y = other.coerce self
      x.major other
    end
  end

  # Get smaller number of two numbers
  #
  # @param [Numeric] other The other number.
  #
  # @return [Numeric] The smaller number of the two.
  def minor( other )
    if other.is_a? Numeric
      ( self <= other ).conditional self, other
    else
      x, y = other.coerce self
      x.minor other
    end
  end

end

# The +Array+ class is extended with a few methods
class Array

  # Element-wise operation based on element and its index
  #
  # Same as +Array#collect+ but with index.
  #
  # @param &action Closure accepting an element and an index.
  #
  # @return [Array<Object>] Array with results.
  def collect_with_index( &action )
    zip( ( 0 ... size ).to_a ).collect &action
  end

end

begin
  require 'continuation'
rescue Exception
end
require 'complex'
require 'malloc'
require 'rbconfig'
require 'set'
require 'thread'
require 'tmpdir'
require 'multiarray/malloc'
require 'multiarray/list'
require 'multiarray/node'
require 'multiarray/element'
require 'multiarray/composite'
require 'multiarray/store'
require 'multiarray/random'
require 'multiarray/object'
require 'multiarray/index'
require 'multiarray/bool'
require 'multiarray/int'
require 'multiarray/float'
require 'multiarray/pointer'
require 'multiarray/variable'
require 'multiarray/lambda'
require 'multiarray/lookup'
require 'multiarray/elementwise'
require 'multiarray/inject'
require 'multiarray/diagonal'
require 'multiarray/histogram'
require 'multiarray/lut'
require 'multiarray/integral'
require 'multiarray/operations'
require 'multiarray/methods'
require 'multiarray/rgb'
require 'multiarray/complex'
require 'multiarray/sequence'
require 'multiarray/multiarray'
require 'multiarray/shortcuts'
require 'multiarray/gcctype'
require 'multiarray/gccvalue'
require 'multiarray/gcccontext'
require 'multiarray/gcccache'
require 'multiarray/gccfunction'

# Namespace of Hornetseye computer vision library
module Hornetseye

  # Method for performing computations in lazy mode resulting in a lazy expression
  #
  # @param [Array<Integer>] *shape Optional shape of result. The method
  # attempts to infer the shape if not specified.
  # @yield Operation to compute array elements lazily.
  #
  # @return [Object,Node] Lazy term to compute later.
  def lazy( *shape, &action )
    previous = Thread.current[ :lazy ]
    Thread.current[ :lazy ] = true
    begin
      options = shape.last.is_a?( Hash ) ? shape.pop : {}
      arity = options[ :arity ] || [ action.arity, shape.size ].max
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

  # Method for performing a lazy computation and then forcing the result
  #
  # @param [Array<Integer>] *shape Optional shape of result. The method
  # attempts to infer the shape if not specified.
  # @yield Operation computing array elements.
  #
  # @return [Object,Node] Result of computation.
  def finalise( *shape, &action )
    previous = Thread.current[ :lazy ]
    Thread.current[ :lazy ] = false
    begin
      retval = lazy *shape, &action
      retval.is_a?( Node ) ? retval.force : retval
    ensure
      Thread.current[ :lazy ] = previous
    end
  end

  module_function :finalise

  # Method for summing values
  #
  # @param [Array<Integer>] *shape Optional shape of result. The method
  # attempts to infer the shape if not specified.
  # @yield Operation returning array elements.
  #
  # @return [Object,Node] Sum of values.
  def sum( *shape, &action )
    options = shape.last.is_a?( Hash ) ? shape.pop : {}
    arity = options[ :arity ] || [ action.arity, shape.size ].max
    if arity <= 0
      term = action.call
      term.is_a?( Node ) ? term.to_type( term.typecode.maxint ) : term
    else
      index = Variable.new shape.empty? ? Hornetseye::INDEX( nil ) :
                           Hornetseye::INDEX( shape.pop )
      term = sum *( shape + [ :arity => arity - 1 ] ) do |*args|
        action.call *( args + [ index ] )
      end
      var1 = Variable.new term.typecode
      var2 = Variable.new term.typecode
      Inject.new( term, index, nil, var1 + var2, var1, var2 ).force
    end
  end

  module_function :sum

end
