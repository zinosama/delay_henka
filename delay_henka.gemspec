$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "delay_henka/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "delay_henka"
  s.version     = DelayHenka::VERSION
  s.authors     = ["zino"]
  s.email       = ["rhu5@u.rochester.edu"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of DelayHenka."
  s.description = "TODO: Description of DelayHenka."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.2.1", ">= 5.2.1.1"

  s.add_development_dependency "sqlite3"
end
