#!/usr/bin/env ruby
require 'date'
require 'rake/clean'
require 'rake/testtask'
require 'rake/packagetask'
require 'rbconfig'

PKG_NAME = 'multiarray'
PKG_VERSION = '0.3.0'
RB_FILES = FileList[ 'lib/**/*.rb' ]
TC_FILES = FileList[ 'test/tc_*.rb' ]
TS_FILES = FileList[ 'test/ts_*.rb' ]
PKG_FILES = [ 'Rakefile', 'README', 'COPYING', '.document' ] +
            RB_FILES + TS_FILES + TC_FILES
SUMMARY = %q{Multi-dimensional and uniform Ruby arrays}
DESCRIPTION = %q{This Ruby-extension defines Hornetseye::MultiArray and other native datatypes. Hornetseye::MultiArray provides multi-dimensional Ruby arrays with elements of same type. The extension is designed to be mostly compatible with Masahiro Tanaka's NArray. However it allows the definition of custom element types and operations on them. This work was also inspired by Ronald Garcia's boost::multi_array and by Todd Veldhuizen's Blitz++.}
AUTHOR = %q{Jan Wedekind}
EMAIL = %q{jan@wedesoft.de}
HOMEPAGE = %q{http://wedesoft.github.com/multiarray/}

SITELIBDIR = Config::CONFIG[ 'sitelibdir' ]

task :default => :all

desc 'Do nothing (default)'
task :all do
end

desc 'Install Ruby extension'
task :install do
  verbose true do
    for f in RB_FILES do
      FileUtils.mkdir_p "#{$SITELIBDIR}/#{File.dirname( f[ 4 .. -1 ] )}"
      FileUtils.cp_r f, "#{$SITELIBDIR}/#{f[ 4 .. -1 ]}"
    end
  end
end

desc 'Uninstall Ruby extension'
task :uninstall do
  verbose true do
    for f in RB_FILES do
      FileUtils.rm_f "#{$SITELIBDIR}/#{f[ 4 .. -1 ]}"
    end
  end
end

Rake::TestTask.new do |t|
  t.test_files = TC_FILES
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new :yard do |y|
    y.options << '--no-private'
    y.files << FileList[ 'lib/**/*.rb' ]
  end
rescue LoadError
  STDERR.puts 'Please install \'yard\' if you want to generate documentation'
end

Rake::PackageTask.new PKG_NAME, PKG_VERSION do |p|
  p.need_tar = true
  p.package_files = PKG_FILES
end

begin
  require 'rubygems/builder'
  $SPEC = Gem::Specification.new do |s|
    s.name = PKG_NAME
    s.version = PKG_VERSION
    s.platform = Gem::Platform::RUBY
    s.date = Date.today.to_s
    s.summary = SUMMARY
    s.description = DESCRIPTION
    s.author = AUTHOR
    s.email = EMAIL
    s.homepage = HOMEPAGE
    s.files = PKG_FILES
    s.test_files = TC_FILES
    s.require_paths = [ 'lib' ]
    s.rubyforge_project = %q{hornetseye}
    s.extensions = %w{Rakefile}
    s.has_rdoc = 'yard'
    s.extra_rdoc_files = []
    s.rdoc_options = %w{--no-private}
    s.add_dependency %q<malloc>, [ '~> 0.2' ]
  end
  GEM_SOURCE = "#{PKG_NAME}-#{PKG_VERSION}.gem"
  desc "Build the gem file #{GEM_SOURCE}"
  task :gem => [ "pkg/#{GEM_SOURCE}" ]
  file "pkg/#{GEM_SOURCE}" => [ 'pkg' ] + $SPEC.files do
    Gem::Builder.new( $SPEC ).build
    verbose true do
      FileUtils.mv GEM_SOURCE, "pkg/#{GEM_SOURCE}"
    end
  end
rescue LoadError
  STDERR.puts 'Please install \'rubygems\' if you want to create Gem packages'
end

CLOBBER.include 'doc'