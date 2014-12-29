Gem::Specification.new do |s|
  s.name        = 'ralbum'
  s.version     = '0.0.0'
  s.date        = '2014-12-29'
  s.summary     = "A static web album generator"
  s.description = "Generate static web album pages from your images and a template."
  s.authors     = ["Alexander Schenkel"]
  s.email       = 'alex@alexi.ch'
  s.files       = Dir["bin/*"] + Dir["lib/*.rb"] + Dir["lib/**/*.rb"] + Dir["templates/**/*"]
  s.executables << 'ralbum.rb'
  s.homepage    = 'https://github.com/bylexus/ralbum'
  s.license     = 'copyright 2014'
  s.add_runtime_dependency "json",
    [">= 0"]
  s.add_runtime_dependency "rmagick",
    ["~> 2.13.3"]
  s.add_runtime_dependency "commander",
    [">= 0"]
  s.add_development_dependency "rspec",
    [">= 0"]
end