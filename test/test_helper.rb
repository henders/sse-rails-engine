# frozen_string_literal: true

# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require 'bundler/setup'
require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start if ENV['CODECLIMATE_REPO_TOKEN']

require File.expand_path('../test/dummy/config/environment.rb', __dir__)
require 'rails/test_help'
require 'minitest/rails'
require 'mocha/setup'

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# https://github.com/rails/rails/issues/31324
Minitest::Rails::TestUnit = Rails::TestUnit if ActionPack::VERSION::STRING == '5.2.0'

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path('fixtures', __dir__)
  ActiveSupport::TestCase.fixtures :all
end
