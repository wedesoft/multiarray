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
require 'tmpdir'
require 'rbconfig'
require 'multiarray'

include Hornetseye

class GCCType
  def initialize( typecode )
    @typecode = typecode
  end
  def identifier
    case @typecode
    when nil
      'void'
    when BYTE
      'char'
    when UBYTE
      'unsigned char'
    when SINT
      'short int'
    when USINT
      'unsigned short int'
    when INT
      'int'
    when UINT
      'unsigned int'
    else
      if @typecode < Pointer_
        'void *'
      elsif @typecode < INDEX_
        'int'
      else
        raise "No identifier available for #{@typecode.inspect}"
      end
    end
  end
  def r2c
    case @typecode
    when BYTE, UBYTE, SINT, USINT, INT, UINT
      'NUM2INT'
    else
      if @typecode < Pointer_
        "(#{identifier})mallocToPtr"
      else
        raise "No conversion available for #{@typecode.inspect}"
      end
    end
  end
end

class GCCValue
  def initialize( function, descriptor ) 
    @function = function
    @descriptor = descriptor
  end
  def inspect
    @descriptor
  end
  def to_s
    @descriptor
  end
  def demand( typecode )
    result = @function.variable( typecode, 'v' ).get
    @function << "#{@function.indent}#{result} = #{self};\n"
    result
  end
  def store( value )
    @function << "#{@function.indent}#{self} = #{value};\n"
    value
  end
  def compilable?
    false
  end
  def load( typecode )
    GCCValue.new @function, "*(#{GCCType.new( typecode ).identifier} *)( #{self} )"
  end
  def save( value )
    @function << "#{@function.indent}*(#{GCCType.new( value.typecode ).identifier} *)( #{self} ) = #{value.get};\n"
  end
  def -@
    GCCValue.new @function, "-( #{self} )"
  end
  def +( other )
    GCCValue.new @function, "( #{self} ) + ( #{other} )"
  end
  def -( other )
    GCCValue.new @function, "( #{self} ) - ( #{other} )"
  end
  def *( other )
    GCCValue.new @function, "( #{self} ) * ( #{other} )"
  end
  def times( &action )
    i = @function.variable INT, 'i'
    @function << "#{@function.indent}for ( #{i.get} = 0; #{i.get} != #{self}; #{i.get}++ ) {\n"
    @function.indent_offset +1
    action.call i.get
    @function.indent_offset -1
    @function << "#{@function.indent}};\n"
  end
end

class GCCContext

  LDSHARED = Config::CONFIG[ 'LDSHARED' ] # c:\mingw\bin\gcc
  STRIP = Config::CONFIG[ 'STRIP' ]
  RUBYHDRDIR = Config::CONFIG.member?( 'rubyhdrdir' ) ?
                "-I#{Config::CONFIG['rubyhdrdir']} " +
                "-I#{Config::CONFIG['rubyhdrdir']}/#{Config::CONFIG['arch']}" :
                "-I#{Config::CONFIG['archdir']}"
  LIBRUBYARG = Config::CONFIG[ 'LIBRUBYARG' ]
  DIRNAME = "#{Dir.tmpdir}/hornetseye"
  Dir.mkdir DIRNAME, 0700 unless File.exist? DIRNAME
  @@dir = File.new DIRNAME
  unless @@dir.flock File::LOCK_EX | File::LOCK_NB
    raise "Could not lock directory #{DIRNAME}"
  end
  @@dir.chmod 0700

  class << self
    @@lib_name = 'hornetseye_aaaaaaaa'
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
  ' ' + ( 0 ... param_types.size ).collect do |i|
    "#{param_types[ i ].identifier} param#{i}"
  end.join( ', ' ) + ' '
end
}) {
EOS

    @wrappers << <<EOS
VALUE wrap#{descriptor.capitalize}( VALUE rbSelf#{
( 0 ... param_types.size ).inject '' do |s,i|
   s << ", VALUE rbParam#{i}"
end
} )
{
  #{descriptor}(#{
if param_types.empty?
  ''
else
  s = ' ' + ( 0 ... param_types.size ).collect do |i|
    "#{param_types[ i ].r2c}( rbParam#{i} )"
  end.join( ', ' ) + ' '
end
});
  return Qnil;
}
EOS

    @registrations << <<EOS
  rb_define_method( cGCCContext, "#{descriptor}",
                    RUBY_METHOD_FUNC( wrap#{descriptor.capitalize} ),
                    #{param_types.size} ); 
EOS
  end
  def compile
    template = <<EOS
#include <ruby.h>

inline void *mallocToPtr( VALUE rbMalloc )
{
  VALUE rbValue = rb_iv_get( rbMalloc, "@value" );
  void *retVal; Data_Get_Struct( rbValue, void, retVal );
  return retVal;
}

#{@instructions}

#{@wrappers}
void Init_#{@lib_name}(void)
{
  VALUE cGCCContext = rb_define_class( "GCCContext", rb_cObject );
#{@registrations}
}
EOS
    # File::EXCL no overwrite
    File.open "#{DIRNAME}/#{@lib_name}.c", 'w', 0600 do |f|
      f << template
    end
    gcc = "#{LDSHARED} -fPIC #{RUBYHDRDIR} -o #{DIRNAME}/#{@lib_name}.so " +
          "#{DIRNAME}/#{@lib_name}.c #{LIBRUBYARG}"
    strip = "#{STRIP} #{DIRNAME}/#{@lib_name}.so"
    # puts template
    system gcc
    system strip
    require "#{DIRNAME}/#{@lib_name}.so"
  end
  def <<( str )
    @instructions << str
    self
  end
end

class GCCCache
end

class GCCFunction
  class << self
    def run( block )
      keys, values, term = block.strip
      labels = Hash[ *keys.zip( ( 0 ... keys.size ).to_a ).flatten ]
      retval = block.pointer_type.new
      retval_keys, retval_values, retval_term = retval.strip
      method_name = '_' + term.descriptor( labels ).
                    tr( '(),+\-*.@', '0123\4567' )
      unless GCCCache.respond_to? method_name
        function = GCCContext.build do |context|
          function = new context, method_name,
                         *( retval_keys + keys ).collect { |var| var.meta }
          term_subst = ( 0 ... keys.size ).collect do |i|
            { keys[i] => function.param( i + retval_keys.size ) }
          end.inject( {} ) { |a,b| a.merge b }
          retval_subst = ( 0 ... retval_keys.size ).collect do |i|
            { retval_keys[ i ] => function.param( i ) }
          end.inject( {} ) { |a,b| a.merge b }
          lazy do
            retval_term.subst( retval_subst ).store term.subst( term_subst )
          end
          function.insn_return
          function.compile
        end
        ( class << GCCCache; self; end ).instance_eval do
          define_method method_name do |*args|
            function.call *args
          end
        end
      end
      puts '_jit_'
      GCCCache.send method_name, *( retval_values + values )
      # retval = retval.demand.get
      retval
    end
  end
  def initialize( context, method_name, *param_types )
    context.function method_name, *param_types.collect { |t| GCCType.new t }
    @context = context
    @method_name = method_name
    @param_types = param_types
    @indent = 1
    @ids = 0
  end
  def compile
    self << '}'
    @context.compile
    self
  end
  def id( prefix )
    @ids += 1
    "%s%02d"% [ prefix, @ids ]
  end
  def variable( typecode, prefix )
    retval = typecode.new GCCValue.new( self, id( prefix ) )
    self << "#{indent}#{GCCType.new( typecode ).identifier} #{retval.get};\n"
    retval
  end
  def indent
    '  ' * @indent
  end
  def indent_offset( offset )
    @indent += offset
  end
  def param( i )
    @param_types[ i ].new GCCValue.new( self, "param#{i}" )
  end
  def call( *args )
    @context.send @method_name, *args.collect { |v| v.get }
  end
  def insn_return( value = nil )
    self << "#{indent}return#{ value ? ' ' + value.get.to_s : '' };\n"
  end
  def <<( str )
    @context << str
    self
  end
end

class Node

  class << self

    def compilable?
      true
    end

  end

  def compilable?
    typecode.compilable?
  end

end

class Element < Node

  def compilable?
    if @value.respond_to? :compilable?
      @value.compilable?
    else
      super
    end
  end

end

class OBJECT < Element

  class << self

    def compilable?
      false
    end

  end

end

class BOOL < Element

  class << self

    def compilable?
      false
    end

  end

end


class Node

  def lazy?
    Thread.current[ :lazy ] or not variables.empty?
  end

  def force
    if lazy?
      self
    else
      # if $jit or is_a?( Element )
      unless compilable?
        Hornetseye::lazy do
          if shape.empty?
            demand
          else
            retval = array_type.new
            retval[] = self
            retval
          end
        end
      else
        GCCFunction.run( self ).demand
      end
    end
  end

end

if true
  Sequence[ 'a', 'b' ] + 'c'
end

if true
i = UBYTE.new( 2 )
j = UBYTE.new( 3 )
puts '--> ' + Binary( :+ ).new( i, j ).inspect
end

if true
s = Sequence[ -1, 3, 5 ]
puts '--> ' + ( -s ).to_a.inspect
end

if true
m = MultiArray.new SINT, 3, 2
for j in 0 ... 2
  for i in 0 ... 3
    m[ j ][ i ] = j * 3 + i - 2
  end
end
puts '--> ' + ( -m ).to_a.inspect
end

if true
m = MultiArray.new SINT, 3, 2
for j in 0 ... 2
  for i in 0 ... 3
    m[ j ][ i ] = j * 3 + i - 2
  end
end
puts '--> ' + ( m + m ).to_a.inspect
end

if true
s = Sequence[ 1, 2, 3 ]
puts '--> ' + s.inject( 4 ) { |a,b| a + b }.inspect
end

if true
s = Sequence[ 1, 2, 3 ]
puts '--> ' + s.inject { |a,b| a + b }.inspect
end

if true
m = MultiArray[ [ 1, 2 ], [ 3, 4 ] ]
puts '--> ' + m.inject( 5 ) { |a,b| a + b }.inspect
end

if true
m = MultiArray[ [ 1, 2 ], [ 3, 4 ] ]
puts '--> ' + m.inject( 5 ) { |a,b| a + b }.inspect
end

# --------------------------------------------------------------------

# add GPL headers
# lazy { Sequence[ 1, 2, 3 ].inject { |a,b| a + b } }[] # does not call JIT!
# JIT 'force'-method? do call JIT for inject
# change Convolve#demand to generate GCC code; tests
# separate secondary operations like equality
# use pid, allow creation of library for pre-loading cache
# Composite numbers?
# pointer-increments for better efficiency
# How does contiguous work here? typecasts?
# Plus#demand: @value1.demand + @value2.demand ???
# nonzero?
# typecasts
# preload cache
# inject without initial is [ 1 .. -1 ].inject with [ 0 ] as initial value

# histogram
# inject: min, max, equal, n-d clips for warp
# block(var1,var2,...) with smart subst?
# lazy( 5 ) { |i| 0 } # but lazy { 0 }
# lazy( 3, 2 ) { |i,j| i }
# lazy( 3, 2 ) { |i,j| j.to_object }

# downsampling after correlation?
# README.rdoc, YARD documentation with pictures, demo video

# f(g(i)) # g(i), f(g(i)) all can be vectors and all can be lazy
# lut(g(i))
# f(warp(i))
#class Node
#  def map( lut, options = {} )
#    
#  end
#end
