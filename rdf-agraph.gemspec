# This is based on https://github.com/bendiken/rdf/blob/master/.gemspec
Gem::Specification.new do |gem|
  gem.version = File.read('VERSION').chomp
  gem.date = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name = 'rdf-agraph'
  gem.homepage = "http://rdf-agraph.rubyforge.org/"
  gem.license = 'Public Domain' if gem.respond_to?(:license)
  gem.summary = "AllegroGraph adapter for RDF.rb"
  gem.description = "An AllegroGraph adapter for use with RDF.rb."
  gem.rubyforge_project = 'rdf-agraph'

  gem.authors = ['Eric Kidd']
  gem.email = 'rdf-agraph@kiddsoftware.com'

  gem.platform = Gem::Platform::RUBY
  gem.files = %w(AUTHORS README.md UNLICENSE VERSION) + Dir.glob('lib/**/*.rb')
  #gem.bindir = %q(bin)
  #gem.executables = %w()
  gem.require_paths = %w(lib)
  gem.has_rdoc = false

  gem.required_ruby_version = '>= 1.8.7'

  gem.add_runtime_dependency 'rdf'
  gem.add_runtime_dependency 'agraph'
  gem.add_runtime_dependency 'json'
  gem.add_runtime_dependency 'rdf-vocab'

  gem.add_development_dependency 'rspec-its'
  gem.add_development_dependency 'rdf-spec'
  gem.add_development_dependency 'yard'  
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'dotenv'
end
