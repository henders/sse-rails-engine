require_dependency "sse_rails_engine/application_controller"

module SseRailsEngine
  class SseController < ApplicationController
    include ActionController::Live

    def connect
      SseRailsEngine.manager.register(response)
      SseRailsEngine.wait_for_disconnect(response)
      render json: {}
    end
  end
end
