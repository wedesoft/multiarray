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

  # Module with meta-programming methods for creating constructor shortcut methods
  module MultiArrayConstructor

    # Meta-programming method for creating constructor shortcut methods
    #
    # @param [Class] target Element-type to create constructor shortcut for.
    #
    # @return [Proc] The new method.
    #
    # @private
    def constructor_shortcut( target )
      define_method target.to_s.downcase do |*args|
        new target, *args
      end
    end

    module_function :constructor_shortcut

    constructor_shortcut OBJECT
    constructor_shortcut BOOL
    constructor_shortcut BYTE
    constructor_shortcut UBYTE
    constructor_shortcut SINT
    constructor_shortcut USINT
    constructor_shortcut INT
    constructor_shortcut UINT
    constructor_shortcut LONG
    constructor_shortcut ULONG
    constructor_shortcut SFLOAT
    constructor_shortcut DFLOAT
    constructor_shortcut SCOMPLEX
    constructor_shortcut DCOMPLEX
    constructor_shortcut BYTERGB
    constructor_shortcut UBYTERGB
    constructor_shortcut SINTRGB
    constructor_shortcut USINTRGB
    constructor_shortcut INTRGB
    constructor_shortcut UINTRGB
    constructor_shortcut LONGRGB
    constructor_shortcut ULONGRGB
    constructor_shortcut SFLOATRGB
    constructor_shortcut DFLOATRGB

  end

  Sequence.extend MultiArrayConstructor

  MultiArray.extend MultiArrayConstructor

  # Module with meta-programming methods for creating conversion shortcut methods
  module MultiArrayConversion

    # Meta-programming method for creating type conversion shortcut methods
    #
    # @param [Class] target Element-type to create type conversion shortcut for.
    #
    # @return [Proc] The new method.
    #
    # @private
    def to_type_shortcut( target )
      define_method "to_#{target.to_s.downcase}" do
        to_type target
      end
    end

    module_function :to_type_shortcut

    to_type_shortcut OBJECT
    to_type_shortcut BOOL
    to_type_shortcut BYTE
    to_type_shortcut UBYTE
    to_type_shortcut SINT
    to_type_shortcut USINT
    to_type_shortcut INT
    to_type_shortcut UINT
    to_type_shortcut LONG
    to_type_shortcut ULONG
    to_type_shortcut SFLOAT
    to_type_shortcut DFLOAT
    to_type_shortcut SCOMPLEX
    to_type_shortcut DCOMPLEX
    to_type_shortcut BYTERGB
    to_type_shortcut UBYTERGB
    to_type_shortcut SINTRGB
    to_type_shortcut USINTRGB
    to_type_shortcut INTRGB
    to_type_shortcut UINTRGB
    to_type_shortcut LONGRGB
    to_type_shortcut ULONGRGB
    to_type_shortcut SFLOATRGB
    to_type_shortcut DFLOATRGB

  end

  Node.class_eval { include MultiArrayConversion }
  Field_.class_eval { include MultiArrayConversion }

  # Module with meta-programming methods for creating shortcut methods for reading images
  module ReaderConversion

    # Meta-programming method for creating shortcut methods for reading images
    #
    # @param [Class] target Element-type to create read method for.
    #
    # @return [Proc] The new method.
    #
    # @private
    def read_shortcut( target )
      define_method "read_#{target.to_s.downcase}" do
        read.to_type target
      end
    end

    module_function :read_shortcut

    read_shortcut OBJECT
    read_shortcut BOOL
    read_shortcut BYTE
    read_shortcut UBYTE
    read_shortcut SINT
    read_shortcut USINT
    read_shortcut INT
    read_shortcut UINT
    read_shortcut LONG
    read_shortcut ULONG
    read_shortcut SFLOAT
    read_shortcut DFLOAT
    read_shortcut SCOMPLEX
    read_shortcut DCOMPLEX
    read_shortcut BYTERGB
    read_shortcut UBYTERGB
    read_shortcut SINTRGB
    read_shortcut USINTRGB
    read_shortcut INTRGB
    read_shortcut UINTRGB
    read_shortcut LONGRGB
    read_shortcut ULONGRGB
    read_shortcut SFLOATRGB
    read_shortcut DFLOATRGB

  end

end

