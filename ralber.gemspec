Gem::Specification.new do |s|
  s.name        = 'ralber'
  s.version     = '0.0.2'
  s.date        = '2014-12-29'
  s.summary     = "A static web album generator"
  s.description = "Generate static web album pages from your images and a template."
  s.authors     = ["Alexander Schenkel"]
  s.email       = 'alex@alexi.ch'
  s.files       = Dir["bin/*"] + Dir["lib/*.rb"] + Dir["lib/**/*.rb"] + Dir["templates/**/*"]
  s.executables << 'ralber.rb'
  s.homepage    = 'https://github.com/bylexus/ralber'
  s.license     = 'copyright 2014'
  s.add_runtime_dependency "json", "~> 1"
  s.add_runtime_dependency "rmagick", "~> 2"
  s.add_runtime_dependency "commander"
  s.add_runtime_dependency "exifr", "~> 1.2"
  s.add_development_dependency "rspec"
  s.required_ruby_version = '~> 2'
end