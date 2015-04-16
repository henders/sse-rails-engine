Rails.application.routes.draw do
  mount SseRailsEngine::Engine => "/sse"
end
