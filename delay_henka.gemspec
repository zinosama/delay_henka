$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "delay_henka/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "delay_henka"
  s.version     = DelayHenka::VERSION
  s.authors     = ["zino"]
  s.email       = ["rhu5@u.rochester.edu"]
  s.homepage    = "https://github.com/zinosama/delay_henka"
  s.summary     = "Rails engine for scheduled changes"
  s.description = "ActiveRecord-based engine for scheduled changes"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency 'rails', '> 5.2'
  s.add_dependency 'haml', '> 5'
  s.add_dependency 'sidekiq', '> 5'
  s.add_dependency 'keka'

  s.add_development_dependency 'pg'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rspec-rails', '3.7.2'
end
