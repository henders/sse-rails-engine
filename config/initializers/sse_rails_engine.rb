# frozen_string_literal: true

require 'rack/lock'
Rails.configuration.middleware.delete Rack::Lock
