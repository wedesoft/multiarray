require 'date'
Gem::Specification.new do |s|
  s.name = %q{multiarray}
  s.version = '0.2.2'
  s.platform = Gem::Platform::RUBY
  s.date = Date.today.to_s
  s.summary = %q{Multi-dimensional and uniform Ruby arrays}
  s.description = %q{This Ruby-extension defines Hornetseye::MultiArray and other native datatypes. Hornetseye::MultiArray provides multi-dimensional Ruby arrays with elements of same type. The extension is designed to be mostly compatible with Masahiro Tanaka's NArray. However it allows the definition of custom element types and operations on them. This work was also inspired by Ronald Garcia's boost::multi_array and by Todd Veldhuizen's Blitz++.}
  s.author = %q{Jan Wedekind}
  s.email = %q{jan@wedesoft.de}
  s.homepage = %q{http://wedesoft.github.com/multiarray/}
  s.files = [ 'source.gemspec', 'Makefile', 'README', 'COPYING' ] +
              Dir.glob( 'lib/*.rb' ) +
              Dir.glob( 'lib/multiarray/*.rb' ) +
              Dir.glob( 'test/*.rb' )
  s.test_files = Dir.glob( 'test/tc_*.rb' )
  s.require_paths = [ 'lib' ]
  s.rubyforge_project = %q{hornetseye}
  s.has_rdoc = 'yard'
  # s.extra_rdoc_files = [ 'README' ]
  # s.rdoc_options = %w{--exclude=/Makefile|.*\.(rb)/ --main README}
  s.add_dependency %q<malloc>, [ '~> 0.2' ]
end
