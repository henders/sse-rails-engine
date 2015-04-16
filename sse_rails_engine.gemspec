$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "sse_rails_engine/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "sse-rails-engine"
  s.version     = SseRailsEngine::VERSION
  s.authors     = ["Shane Hender"]
  s.email       = ["shender@zendesk.com"]
  s.homepage    = "https://github.com/henders/sse-rails-engine"
  s.summary     = "Provides SSE connection tracking and broadcasting of events from anywhere in Rails app"
  s.description = "Provides SSE connection tracking and broadcasting of events from anywhere in Rails app"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.1"
  s.add_development_dependency 'minitest-rails'
end
