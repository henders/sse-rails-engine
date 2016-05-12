require 'rack/lock'
Rails.configuration.middleware.delete Rack::Lock
