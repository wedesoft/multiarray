#!/usr/bin/env ruby
require 'date'
require 'rake/clean'
require 'rake/testtask'
require 'rake/packagetask'
require 'rbconfig'
require_relative 'config'

$SITELIBDIR = RbConfig::CONFIG[ 'sitelibdir' ]

task :default => :all

desc 'Do nothing (default)'
task :all do
end

desc 'Install Ruby extension'
task :install do
  verbose true do
    for f in RB_FILES do
      FileUtils.mkdir_p "#{$SITELIBDIR}/#{File.dirname f.gsub( /^lib\//, '' )}"
      FileUtils.cp_r f, "#{$SITELIBDIR}/#{f.gsub /^lib\//, ''}"
    end
  end
end

desc 'Uninstall Ruby extension'
task :uninstall do
  verbose true do
    for f in RB_FILES do
      FileUtils.rm_f "#{$SITELIBDIR}/#{f.gsub /^lib\//, ''}"
    end
  end
end

Rake::TestTask.new do |t|
  t.test_files = TC_FILES
end

begin
  # For development just run it with "yard server --reload".
  require 'yard'
  YARD::Rake::YardocTask.new :yard do |y|
    y.files << RB_FILES
  end
rescue LoadError
  STDERR.puts 'Please install \'yard\' if you want to generate documentation'
end

Rake::PackageTask.new PKG_NAME, PKG_VERSION do |p|
  p.need_tar = true
  p.package_files = PKG_FILES
end

CLOBBER.include 'doc', '.yardoc'
