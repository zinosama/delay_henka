lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

# Maintain your gem's version:
require "delay_henka/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "delay_henka"
  s.version     = DelayHenka::VERSION
  s.authors     = ["Chowbus"]
  s.email       = ["engineering@chowbus.com"]

  s.homepage    = "https://github.com/FanTuanEats/delay_henka"
  s.summary     = "Rails engine for scheduled changes"
  s.description = "ActiveRecord-based engine for scheduled changes"
  s.license     = "proprietary"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  s.files    = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      # include all factories in the build
      f.match(%r{^(test|spec|features)/})
    end
  end
  s.bindir        = "exe"
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'rails', '> 5.2'
  s.add_dependency 'haml', '> 5'
  s.add_dependency 'sidekiq', '> 5'
  s.add_dependency 'keka', '>= 0.3'

  s.add_development_dependency 'pg'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rspec-rails', '3.7.2'
end
