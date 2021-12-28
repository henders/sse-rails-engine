$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'sse_rails_engine/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'sse-rails-engine'
  s.version     = SseRailsEngine::VERSION
  s.authors     = ['Shane Hender']
  s.email       = ['henders@gmail.com']
  s.homepage    = 'https://github.com/henders/sse-rails-engine'
  s.summary     = 'Provides SSE connection tracking and broadcasting of events from anywhere in Rails app'
  s.description = 'See the README.md at https://github.com/henders/sse-rails-engine'
  s.license     = 'MIT'

  s.files = Dir['{app,config,lib}/**/*', 'LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']
  s.required_ruby_version = '>= 2.3'

  s.add_dependency 'rails', '>= 4.2.0', '< 7.0'
  s.add_development_dependency 'minitest-rails'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'bump'
  s.add_development_dependency 'codeclimate-test-reporter', '~> 0.0' # 1.0 needs some changes
  s.add_development_dependency 'rubocop', '~> 0.0'
end
