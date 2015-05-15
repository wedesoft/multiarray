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

  # Context object for creating a Ruby extension
  #
  # @private
  class GCCContext

    # Ruby configuration
    #
    # @private
    CFG = RbConfig::CONFIG

    if CFG['rubyarchhdrdir']
      CFLAGS = "-DNDEBUG -Wno-unused-function #{CFG[ 'CFLAGS' ]} " +
        "-I#{CFG['rubyhdrdir']} -I#{CFG['rubyarchhdrdir']}"
    elsif CFG[ 'rubyhdrdir' ]
      # GCC compiler flags
      #
      # @private
      CFLAGS = "-DNDEBUG -Wno-unused-function #{CFG[ 'CFLAGS' ]} " +
        "-I#{CFG['rubyhdrdir']} -I#{CFG['rubyhdrdir']}/#{CFG['arch']}"
    else
      CFLAGS = "-DNDEBUG -Wno-unused-function #{CFG[ 'CFLAGS' ]} " +
        "-I#{CFG['archdir']}"
    end

    # Arguments for linking the Ruby extension
    #
    # @private
    LIBRUBYARG = "-L#{CFG[ 'libdir' ]} #{CFG[ 'LIBRUBYARG' ]} #{CFG[ 'LDFLAGS' ]} "
                 "#{CFG[ 'SOLIBS' ]} #{CFG[ 'DLDLIBS' ]}"

    # Command for linking the Ruby extension
    #
    # @private
    LDSHARED = CFG[ 'LDSHARED' ]

    # Shared library file extension under current operating system
    #
    # @private
    DLEXT = CFG[ 'DLEXT' ]

    # Directory for storing the Ruby extensions
    #
    # @private
    DIRNAME = "#{Dir.tmpdir}/hornetseye-ruby#{RUBY_VERSION}-" +
              "#{ENV[ 'USER' ] || ENV[ 'USERNAME' ]}"

    # Lock file to prevent conflicts
    #
    # @private
    LOCKFILE = "#{DIRNAME}/lock"

    Dir.mkdir DIRNAME, 0700 unless File.exist? DIRNAME

    # The actual file lock
    #
    # @private
    @@lock = File.new LOCKFILE, 'w', 0600
    unless @@lock.flock File::LOCK_EX | File::LOCK_NB
      raise "Could not lock file \"#{LOCKFILE}\""
    end

    # Next available base name for a Ruby extension
    #
    # @private
    @@lib_name = 'hornetseye_aaaaaaaa'

    if ENV[ 'HORNETSEYE_PRELOAD_CACHE' ]
      while File.exist? "#{DIRNAME}/#{@@lib_name}.#{DLEXT}"
        require "#{DIRNAME}/#{@@lib_name}"        
        @@lib_name = @@lib_name.succ
      end
    end

    class << self

      # Method for compiling Ruby to C
      #
      # @param [Proc] action The code block needs to accept a GCCContext object.
      #
      # @return [Object] Returns result of code block.
      #
      # @see GCCFunction.run
      #
      # @private
      def build( &action )
        lib_name, @@lib_name = @@lib_name, @@lib_name.succ
        new( lib_name ).build &action
      end

    end

    # Initialises an empty Ruby extension
    #
    # @param [String] lib_name Base name of library to create later.
    #
    # @private
    def initialize( lib_name )
      @lib_name = lib_name
      @c_instructions = ''
      @c_wrappers = ''
      @c_registrations = ''
    end

    # Create Ruby extension
    #
    # @param [Proc] action Code block accepting a GCCContext object.
    #
    # @return [Object] Returns result of code block.
    #
    # @private
    def build( &action )
      action.call self
    end

    # Add a new function to the Ruby extension
    #
    # @param [String] descriptor Method name of function.
    # @param [Array<GCCType>] param_types Array with parameter types.
    #
    # @return [GCCFunction] Object representing the function.
    #
    # @private
    def function( descriptor, *param_types )
      @c_instructions << <<EOS
VALUE #{descriptor}( #{
param_types.collect do |t|
  t.identifiers
end.flatten.collect_with_index do |ident,i|
  "#{ident} param#{i}"
end.join ', '
} )
{
EOS

      @c_wrappers << <<EOS
VALUE wrap#{descriptor.capitalize}( int argc, VALUE *argv, VALUE rbSelf )
{
  #{descriptor}( #{
param_types.collect do |t|
  t.r2c
end.flatten.collect_with_index do |conv,i|
  "#{conv.call "argv[#{i}]"}"
end.join ', '
  } );
  return Qnil;
}
EOS

      @c_registrations << <<EOS
  rb_define_singleton_method(cGCCCache, "#{descriptor}",
                             RUBY_METHOD_FUNC( wrap#{descriptor.capitalize} ), -1); 
EOS
    end

    # Compile the Ruby extension
    #
    # This method writes the source code to a file and calls GCC to compile it.
    # Finally the Ruby extension is loaded.
    #
    # @return [Boolean] Returns of loading the Ruby extension.
    #
    # @private
    def compile
      c_template = <<EOS
/* This file is generated automatically. It is pointless to edit this file. */
#include <ruby.h>
#include <math.h>

inline void *mallocToPtr( VALUE rbMalloc )
{
  void *retVal; Data_Get_Struct( rbMalloc, void, retVal );
  return retVal;
}

static unsigned long make_mask( unsigned long x )
{
  x = x | x >> 1;
  x = x | x >> 2;
  x = x | x >> 4;
  x = x | x >> 8;
  x = x | x >> 16;
#if 4 < SIZEOF_LONG
  x = x | x >> 32;
#endif
  return x;
}

static unsigned long limited_rand(unsigned long limit)
{
  int i;
  unsigned long mask, val;
  if (limit < 2) return 0;
  mask = make_mask(limit - 1);
  retry:
  val = 0;
  for (i = SIZEOF_LONG / 4 - 1; 0 <= i; i--) {
    if ((mask >> (i * 32)) & 0xffffffff) {
      val |= (unsigned long)rb_genrand_int32() << (i * 32);
      val &= mask;
      if (limit <= val)
        goto retry;
    };
  };
  return val;
}

#{@c_instructions}

#{@c_wrappers}
void Init_#{@lib_name}(void)
{
  VALUE mHornetseye = rb_define_module("Hornetseye");
  VALUE cGCCCache = rb_define_class_under(mHornetseye, "GCCCache", rb_cObject);
#{@c_registrations}
}
EOS
      # File::EXCL no overwrite
      File.open "#{DIRNAME}/#{@lib_name}.c", 'w', 0600 do |f|
        f << c_template
      end
      gcc = "#{LDSHARED} #{CFLAGS} -o #{DIRNAME}/#{@lib_name}.#{DLEXT} " +
            "#{DIRNAME}/#{@lib_name}.c #{LIBRUBYARG}"
      # puts c_template
      # puts gcc
      raise "The following command failed: #{gcc}" unless system gcc
      require "#{DIRNAME}/#{@lib_name}"
    end

    # Add instructions to Ruby extension
    #
    # The given string is appended to the source code of the Ruby extension.
    #
    # @param [String] str String with source code fragment of Ruby extension.
    #
    # @return [GCCContext] Returns +self+.
    #
    # @private
    def <<( str )
      @c_instructions << str
      self
    end

  end

end
