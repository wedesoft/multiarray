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

  # An overloadable while loop
  #
  # @param [Proc] action The loop body
  #
  # @return [NilClass] Returns +nil+.
  #
  # @private
  def while( &action )
    action.call while call.get
    nil
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

  def matched?
    false
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
    unless other.matched?
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
    unless other.matched?
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
    unless other.matched?
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
    unless other.matched?
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

  # Conditional operation
  #
  # @param [Proc] action Action to perform if condition is +true+.
  #
  # @return [Object] The return value should be ignored.
  def if( &action )
    action.call
  end

  # Conditional operation
  #
  # @param [Proc] action1 Action to perform if condition is +true+.
  # @param [Proc] action2 Action to perform if condition is +false+.
  #
  # @return [Object] The return value should be ignored.
  def if_else( action1, action2 )
    action1.call
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
    unless other.matched?
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
    unless other.matched?
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

  # Conditional operation
  #
  # @param [Proc] action Action to perform if condition is +true+.
  #
  # @return [Object] The return value should be ignored.
  def if( &action )
  end

  # Conditional operation
  #
  # @param [Proc] action1 Action to perform if condition is +true+.
  # @param [Proc] action2 Action to perform if condition is +false+.
  #
  # @return [Object] The return value should be ignored.
  def if_else( action1, action2 )
    action2.call
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
    unless other.matched?
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
    unless other.matched?
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

  # Conditional operation
  #
  # @param [Proc] action Action to perform if condition is +true+.
  #
  # @return [Object] The return value should be ignored.
  def if( &action )
  end

  # Conditional operation
  #
  # @param [Proc] action1 Action to perform if condition is +true+.
  # @param [Proc] action2 Action to perform if condition is +false+.
  #
  # @return [Object] The return value should be ignored.
  def if_else( action1, action2 )
    action2.call
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
      if other.matched?
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

  class << self

    # Compute Gauss blur filter
    #
    # Compute a filter for approximating a Gaussian blur. The size of the
    # filter is determined by the given error bound.
    #
    # @param [Float] sigma Spread of blur filter.
    # @param [Float] max_error Upper bound for filter error.
    # 
    # @return [Array] An array with the filter elements.
    def gauss_blur_filter( sigma, max_error = 1.0 / 0x100 )
      # Error function
      #
      # @param [Float] x Function argument
      # @param [Float] sigma Function parameter
      #
      # @private
      def erf(x, sigma)
        0.5 * Math.erf( x / ( Math.sqrt( 2.0 ) * sigma.abs ) )
      end
      raise 'Sigma must be greater than zero.' if sigma <= 0
      # Integral of Gauss-bell from -0.5 to +0.5.
      integral = erf( +0.5, sigma ) - erf( -0.5, sigma )
      retVal = [ integral ]
      while 1.0 - integral > max_error
        # Integral of Gauss-bell from -size2 to +size2.
        size2 = 0.5 * ( retVal.size + 2 )
        nIntegral = erf( +size2, sigma ) - erf( -size2, sigma )
        value = 0.5 * ( nIntegral - integral )
        retVal.unshift value
        retVal.push value
        integral = nIntegral
      end
      # Normalise result.
      retVal.collect { |element| element / integral }
    end

    # Compute Gauss gradient filter
    #
    # Compute a filter for approximating a Gaussian gradient. The size of the
    # filter is determined by the given error bound.
    #
    # @param [Float] sigma Spread of blur filter.
    # @param [Float] max_error Upper bound for filter error.
    # 
    # @return [Array] An array with the filter elements.
    def gauss_gradient_filter( sigma, max_error = 1.0 / 0x100 )
      # Gaussian function
      #
      # @param [Float] x Function argument
      # @param [Float] sigma Function parameter
      #
      # @private
      def gauss(x, sigma)
        1.0 / ( Math.sqrt( 2.0 * Math::PI ) * sigma.abs ) *
          Math.exp( -x**2 / ( 2.0 * sigma**2 ) )
      end
      raise 'Sigma must be greater than zero.' if sigma <= 0
      # Integral of Gauss-gradient from -0.5 to +0.5.
      retVal = [ gauss( +0.5, sigma ) - gauss( -0.5, sigma ) ]
      # Absolute integral of Gauss-gradient from 0.5 to infinity.
      integral = gauss( 0.5, sigma )
      sumX = 0
      while 2.0 * integral > max_error
        size2 = 0.5 * ( retVal.size + 2 )
        nIntegral = gauss( size2, sigma )
        value = integral - nIntegral
        retVal.unshift +value
        retVal.push -value
        sumX += value * ( retVal.size - 1 )
        integral = nIntegral
      end
      retVal.collect { |element| element / sumX }
    end

  end

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

  def strip
    collect { |arg| arg.strip }.inject [[], [], []] do |retval,s|
      [retval[0] + s[0], retval[1] + s[1], retval[2] + [s[2]]]
    end
  end

end

class String
  def method_name
    tr '(),+\-*/%.@?~&|^<=>', '0123\456789ABCDEFGH'
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
require 'multiarray/argument'
require 'multiarray/histogram'
require 'multiarray/lut'
require 'multiarray/integral'
require 'multiarray/mask'
require 'multiarray/unmask'
require 'multiarray/components'
require 'multiarray/field'
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
        term = Node.match(term).new term unless term.matched?
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
      retval.matched? ? retval.force : retval
    ensure
      Thread.current[ :lazy ] = previous
    end
  end

  module_function :finalise

  # Method for specifying injections in a different way
  #
  # @overload inject(*shape, op, &action)
  #   @param [Array<Integer>] *shape Optional shape of result.
  #   @param [Proc] op Block of injection.
  #   @yield Operation returning array elements.
  #
  # @return [Object,Node] Sum of values.
  #
  # @private
  def inject(*shape, &action)
    op = shape.pop
    options = shape.last.is_a?(Hash) ? shape.pop : {}
    arity = options[:arity] || [action.arity, shape.size].max
    if arity <= 0
      term = action.call
      term.matched? ? term.to_type(term.typecode.maxint) : term
    else
      index = Variable.new shape.empty? ? Hornetseye::INDEX(nil) :
                           Hornetseye::INDEX(shape.pop)
      term = inject *(shape + [:arity => arity - 1] + [op]) do |*args|
        action.call *(args + [index])
      end
      var1 = Variable.new term.typecode
      var2 = Variable.new term.typecode
      Inject.new(term, index, nil, op.call(var1, var2), var1, var2).force
    end
  end

  module_function :inject

  # Method for summing values
  #
  # @param [Array<Integer>] *shape Optional shape of result.
  # @yield Operation returning array elements.
  #
  # @return [Object,Node] Sum of values.
  def sum(*shape, &action)
    inject *(shape + [proc { |a,b| a + b }]), &action
  end

  module_function :sum

  # Method for computing product of values
  #
  # @param [Array<Integer>] *shape Optional shape of result.
  # @yield Operation returning array elements.
  #
  # @return [Object,Node] Product of values.
  def prod(*shape, &action)
    inject *(shape + [proc { |a,b| a * b }]), &action
  end

  module_function :prod

  # Method for computing minimum of values
  #
  # @param [Array<Integer>] *shape Optional shape of result.
  # @yield Operation returning array elements.
  #
  # @return [Object,Node] Minimum of values.
  def min(*shape, &action)
    inject *(shape + [proc { |a,b| a.minor b }]), &action
  end

  module_function :min

  # Method for computing maximum of values
  #
  # @param [Array<Integer>] *shape Optional shape of result.
  # @yield Operation returning array elements.
  #
  # @return [Object,Node] Maximum of values.
  def max(*shape, &action)
    inject *(shape + [proc { |a,b| a.major b }]), &action
  end

  module_function :max

  def argument(block, options = {}, &action)
    arity = options[:arity] || action.arity
    if arity > 0
      indices = options[:indices] ||
                (0 ... arity).collect { Variable.new Hornetseye::INDEX(nil) }
      term = options[:term] || action.call(*indices)
      slices = indices[0 ... -1].inject(term) { |t,index| Lambda.new index, t }
      var1 = options[:var1] || Variable.new(term.typecode)
      var2 = options[:var2] || Variable.new(term.typecode)
      block = options[:block] || block.call( var1, var2 )
      lut = Argument.new(slices, indices.last, block, var1, var2, INT.new(0)).force
      arr = options[:arr] || Lambda.new(indices.last, slices)
      id = (0 ... arr.dimension - 1).collect { |j| lazy(*arr.shape[0 ... -1]) { |*i| i[j] } }
      lut = INT.new(lut) unless lut.matched?
      sub_arr = Lut.new(*(id + [lut] + [arr])).force
      indices = (0 ... arity - 1).collect { Variable.new Hornetseye::INDEX(nil) }
      term = indices.reverse.inject(sub_arr) { |t,index| t.element index }
      sub_arg = argument nil, :arity => arity - 1, :indices => indices, :term => term,
                         :arr => sub_arr, :block => block, :var1 => var1, :var2 => var2
      if sub_arg.empty?
        [lut[]]
      elsif sub_arg.first.is_a? Integer
        sub_arg + [lut[*sub_arg]]
      else
        id = (sub_arg.size ... lut.dimension).collect do |i|
          lazy(*sub_arg.first.shape) { |*j| j[i - lut.dimension + sub_arg.first.dimension] }
        end
        sub_arg + [lut.warp(*(sub_arg + id))]
      end
    else
      []
    end
  end

  module_function :argument
  
  def argmax(&action)
    argument proc { |a,b| a > b }, &action
  end

  module_function :argmax

  def argmin(&action)
    argument proc { |a,b| a < b }, &action
  end

  module_function :argmin

end
 
