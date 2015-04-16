Rails.application.routes.draw do

  mount SseRailsEngine::Engine => "/sse_rails_engine"
end
