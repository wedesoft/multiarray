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

  # Module providing the methods to manipulate array expressions
  module Methods

    # Extend some methods in the specified module
    #
    # @param [Module] mod The mathematics module.
    # @return The return value should be ignored.
    #
    # @private
    def Methods.included( mod )
      define_unary_method  mod, :sqrt , :float
      define_unary_method  mod, :log  , :float
      define_unary_method  mod, :log10, :float
      define_unary_method  mod, :exp  , :float
      define_unary_method  mod, :cos  , :float
      define_unary_method  mod, :sin  , :float
      define_unary_method  mod, :tan  , :float
      define_unary_method  mod, :acos , :float
      define_unary_method  mod, :asin , :float
      define_unary_method  mod, :atan , :float
      define_unary_method  mod, :cosh , :float
      define_unary_method  mod, :sinh , :float
      define_unary_method  mod, :tanh , :float
      define_unary_method  mod, :acosh, :float
      define_unary_method  mod, :asinh, :float
      define_unary_method  mod, :atanh, :float
      define_binary_method mod, :atan2, :floating
      define_binary_method mod, :hypot, :floating
    end

    # Extend unary method with capability to handle arrays
    #
    # @param [Module] mod The mathematics module.
    # @param [Symbol,String] op The unary method to extend.
    # @param [Symbol,String] conversion A method for doing the type conversion.
    # @return [Proc] The new method.
    #
    # @private
    def define_unary_method( mod, op, conversion = :identity )
      mod.module_eval do
        define_method "#{op}_with_hornetseye" do |a|
          if a.is_a?(Node) or a.is_a?(Field_)
            if a.dimension == 0 and a.variables.empty?
              target = a.typecode.send conversion
              target.new mod.send( op, a.simplify.get )
            else
              Hornetseye::ElementWise( lambda { |x| mod.send op, x },
                                       "#{mod}.#{op}",
                                       lambda { |x| x.send conversion } ).
                new(a.sexp).force
            end
          else
            send "#{op}_without_hornetseye", a
          end
        end
        alias_method_chain op, :hornetseye
        module_function "#{op}_without_hornetseye"
        module_function op
      end
    end

    module_function :define_unary_method

    # Extend binary method with capability to handle arrays
    #
    # @param [Module] mod The mathematics module.
    # @param [Symbol,String] op The binary method to extend.
    # @param [Symbol,String] conversion A method for doing the type balancing.
    # @return [Proc] The new method.
    #
    # @private
    def define_binary_method( mod, op, coercion = :coercion )
      mod.module_eval do
        define_method "#{op}_with_hornetseye" do |a,b|
          if a.is_a?(Node) or a.is_a?(Field_) or
             b.is_a?(Node) or b.is_a?(Field_)
            a = Node.match(a, b).new a unless a.is_a?(Node) or a.is_a?(Field_)
            b = Node.match(b, a).new b unless b.is_a?(Node) or b.is_a?(Field_)
            if a.dimension == 0 and a.variables.empty? and
               b.dimension == 0 and b.variables.empty?
              target = a.typecode.send coercion, b.typecode
              target.new mod.send(op, a.simplify.get, b.simplify.get)
            else
              Hornetseye::ElementWise( lambda { |x,y| mod.send op, x, y },
                                       "#{mod}.#{op}",
                                       lambda { |t,u| t.send coercion, u } ).
                new(a.sexp, b.sexp).force
            end
          else
            send "#{op}_without_hornetseye", a, b
          end
        end
        alias_method_chain op, :hornetseye
        module_function "#{op}_without_hornetseye"
        module_function op
      end
    end

    module_function :define_binary_method

  end

end

module Math
  include Hornetseye::Methods
end

