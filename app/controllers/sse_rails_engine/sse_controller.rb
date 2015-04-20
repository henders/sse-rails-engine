require_dependency "sse_rails_engine/application_controller"

module SseRailsEngine
  class SseController < ApplicationController
    def connect
      raise 'This Rack server does not support hijacking, ensure you are using >v1.5 of Rack' unless request.env['rack.hijack?']
      SseRailsEngine.manager.register(response)
      render json: {}
    end
  end
end
