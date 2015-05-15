require 'rake'

PKG_NAME = 'multiarray'
PKG_VERSION = '1.0.4'
RB_FILES = FileList[ 'config.rb', 'lib/**/*.rb' ]
TC_FILES = FileList[ 'test/tc_*.rb' ]
TS_FILES = FileList[ 'test/ts_*.rb' ]
PKG_FILES = [ 'Rakefile', 'README.md', 'COPYING', '.document' ] +
            RB_FILES + TS_FILES + TC_FILES
BIN_FILES = [ 'README.md', 'COPYING', '.document' ] +
            RB_FILES + TS_FILES + TC_FILES
SUMMARY = %q{Multi-dimensional and uniform Ruby arrays}
DESCRIPTION = %q{This Ruby-extension defines Hornetseye::MultiArray and other native datatypes. Hornetseye::MultiArray provides multi-dimensional Ruby arrays with elements of same type. The extension is designed to be mostly compatible with Masahiro Tanaka's NArray. However it allows the definition of custom element types and operations on them. This work was also inspired by Ronald Garcia's boost::multi_array and by Todd Veldhuizen's Blitz++.}
LICENSE = 'GPL-3+'
AUTHOR = %q{Jan Wedekind}
EMAIL = %q{jan@wedesoft.de}
HOMEPAGE = %q{http://wedesoft.github.com/multiarray/}

