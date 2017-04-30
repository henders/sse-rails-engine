# frozen_string_literal: true

SseRailsEngine::Engine.routes.draw do
  root to: SseRailsEngine.manager
end
