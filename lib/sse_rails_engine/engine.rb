module SseRailsEngine
  class Engine < ::Rails::Engine
    isolate_namespace SseRailsEngine

    config.sse_rails_engine = SseRailsEngine
  end
end
