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
  
  class GCCContext

    CFG = RbConfig::CONFIG
    if CFG[ 'rubyhdrdir' ]
      CFLAGS = "-DNDEBUG #{CFG[ 'CFLAGS' ]} " +
        "-I#{CFG['rubyhdrdir']} -I#{CFG['rubyhdrdir']}/#{CFG['arch']}"
    else
      CFLAGS = "-DNDEBUG #{CFG[ 'CFLAGS' ]} " +
        "-I#{CFG['archdir']}"
    end
    LIBRUBYARG = "-L#{CFG[ 'libdir' ]} #{CFG[ 'LIBRUBYARG' ]} #{CFG[ 'LDFLAGS' ]} "
                 "#{CFG[ 'SOLIBS' ]} #{CFG[ 'DLDLIBS' ]}"
    LDSHARED = CFG[ 'LDSHARED' ]
    DLEXT = CFG[ 'DLEXT' ]
    DIRNAME = "#{Dir.tmpdir}/hornetseye-ruby#{RUBY_VERSION}-" +
              "#{ENV[ 'USER' ] || ENV[ 'USERNAME' ]}"
    LOCKFILE = "#{DIRNAME}/lock"
    Dir.mkdir DIRNAME, 0700 unless File.exist? DIRNAME
    @@lock = File.new LOCKFILE, 'w', 0600
    unless @@lock.flock File::LOCK_EX | File::LOCK_NB
      raise "Could not lock file \"#{LOCKFILE}\""
    end

    @@lib_name = 'hornetseye_aaaaaaaa'

    if ENV[ 'HORNETSEYE_PRELOAD_CACHE' ]
      while File.exist? "#{DIRNAME}/#{@@lib_name}.#{DLEXT}"
        require "#{DIRNAME}/#{@@lib_name}"        
        @@lib_name = @@lib_name.succ
      end
    end

    class << self

      def build( &action )
        lib_name, @@lib_name = @@lib_name, @@lib_name.succ
        new( lib_name ).build &action
      end

    end

    def initialize( lib_name )
      @lib_name = lib_name
      @instructions = ''
      @wrappers = ''
      @registrations = ''
    end

    def build( &action )
      action.call self
    end

    def function( descriptor, *param_types )
      @instructions << <<EOS
void #{descriptor}(#{
if param_types.empty?
  ''
else
  ' ' + param_types.collect do |t|
    t.identifiers
  end.flatten.collect_with_index do |ident,i|
    "#{ident} param#{i}"
  end.join( ', ' ) + ' '
end
}) {
EOS

      @wrappers << <<EOS
VALUE wrap#{descriptor.capitalize}( int argc, VALUE *argv, VALUE rbSelf )
{
  #{descriptor}(#{
if param_types.empty?
  ''
else
  s = ' ' + param_types.collect do |t|
    t.r2c
  end.flatten.collect_with_index do |conv,i|
    conv.call "argv[ #{i} ]"
  end.join( ', ' ) + ' '
end
});
  return Qnil;
}
EOS

      @registrations << <<EOS
  rb_define_singleton_method( cGCCCache, "#{descriptor}",
                    RUBY_METHOD_FUNC( wrap#{descriptor.capitalize} ), -1 ); 
EOS
    end
    def compile
      template = <<EOS
#include <ruby.h>
#include <math.h>

inline void *mallocToPtr( VALUE rbMalloc )
{
  void *retVal; Data_Get_Struct( rbMalloc, void, retVal );
  return retVal;
}

#{@instructions}

#{@wrappers}
void Init_#{@lib_name}(void)
{
  VALUE mHornetseye = rb_define_module( "Hornetseye" );
  VALUE cGCCCache = rb_define_class_under( mHornetseye, "GCCCache",
                                           rb_cObject );
#{@registrations}
}
EOS
      # File::EXCL no overwrite
      File.open "#{DIRNAME}/#{@lib_name}.c", 'w', 0600 do |f|
        f << template
      end
      gcc = "#{LDSHARED} #{CFLAGS} -o #{DIRNAME}/#{@lib_name}.#{DLEXT} " +
            "#{DIRNAME}/#{@lib_name}.c #{LIBRUBYARG}"
      # puts template
      raise "The following command failed: #{gcc}" unless system gcc
      require "#{DIRNAME}/#{@lib_name}"
    end

    def <<( str )
      @instructions << str
      self
    end

  end

end
