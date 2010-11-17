multiarray
==========

**Author**:       Jan Wedekind
**Copyright**:    2010
**License**:      GPL

Synopsis
--------

This Ruby-extension defines the class {Hornetseye::MultiArray} and other native datatypes. {Hornetseye::MultiArray} provides multi-dimensional Ruby arrays with elements of same type. The extension is designed to be mostly compatible with Masahiro Tanaka's NArray. However it allows the definition of custom element types and operations on them. This work was also inspired by Ronald Garcia's boost::multi_array and by Todd Veldhuizen's Blitz++.

Installation
------------

To install this Ruby extension, use the following command:

    $ sudo gem install multiarray

Alternatively you can install the Ruby extension from source as follows:

    $ sudo rake install

Usage
-----

Simply run Interactive Ruby:

    $ irb

You can load the Ruby extension as shown below. The example shows a few array operations and their results.

    require 'rubygems'
    require 'multiarray'
    include Hornetseye
    m = MultiArray[ [ 2, 3 ], [ 4, 5 ] ]
    # MultiArray(UBYTE,2,2):
    # [ [ 2, 3 ],
    #   [ 4, 5 ] ]
    m[ 1, 0 ]
    # 3
    m[ 0 ][ 1 ]
    # 3
    m + 1
    # MultiArray(UBYTE,2,2):
    # [ [ 3, 4 ],
    #   [ 5, 6 ] ]
    1.0 / m
    # MultiArray(DFLOAT,2,2):
    # [ [ 0.5, 0.3333333333333333 ],
    #   [ 0.25, 0.2 ] ]
    m[ 1 ]
    # Sequence(UBYTE,2):
    # [ 4, 5 ]
    sum { |i,j| m[i,j] }
    # 14
    sum { |j| m[j] }
    # Sequence(UBYTE,2):
    # [ 6, 8 ]
    -m.to_byte
    # MultiArray(BYTE,2,2):
    # [ [ -2, -3 ],
    #   [ -4, -5 ] ]
    
