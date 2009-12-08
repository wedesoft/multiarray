require 'date'
Gem::Specification.new do |s|
  s.name = %q{multiarray}
  s.version = '0.1.0'
  s.platform = Gem::Platform::RUBY
  s.date = Date.today.to_s
  s.summary = %q{Multi-dimensional and uniform Ruby arrays}
  s.description = %q{This gem provides multi-dimensional Ruby arrays with elements of same type. The classes are designed to be mostly compatible with Masahiro Tanaka\'s NArray. However it allows the definition of custom element types and operations on them. This work was also inspired by Ronald Garcia\'s boost::multi_array and by Todd Veldhuizen\'s Blitz++.}
  s.author = %q{Jan Wedekind}
  s.email = %q{jan@wedesoft.de}
  s.homepage = %q{http://wedesoft.github.com/multiarray/}
  s.files = [ 'source.gemspec', 'Makefile', 'README', 'COPYING' ] +
              Dir.glob( 'lib/*.rb' ) +
              Dir.glob( 'lib/multiarray/*.rb' ) +
              [ 'test/ts_multiarray.rb' ]
  s.test_files = [ 'test/ts_multiarray.rb' ]
  s.require_paths = [ 'lib' ]
  s.rubyforge_project = %q{hornetseye}
  s.has_rdoc = true
  s.extra_rdoc_files = [ 'README' ]
  s.rdoc_options = %w{--exclude=/Makefile|.*\.(rb)/ --main README}
  s.add_dependency %q<malloc>, [ '~> 0.1' ]
end
