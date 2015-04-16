module SseRailsEngine
  class SseController < ApplicationController
    include ActionController::Live

    def connect
      Rails.logger.info 'Registering new connection'
      SseRailsEngine.manager.register(response)
      SseRailsEngine.wait_for_disconnect(response)
      Rails.logger.info 'Exiting stream request'
    end
  end
end
