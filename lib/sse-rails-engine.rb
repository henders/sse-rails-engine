require 'sse_rails_engine/engine'
require 'sse_rails_engine/connection'
require 'sse_rails_engine/manager'

module SseRailsEngine
  mattr_accessor :heartbeat_interval

  @@heartbeat_interval = 5.seconds

  def self.manager
    @manager ||= Manager.new
  end

  def self.send_event(name, data)
    manager.send_event(name, data)
  end

  def self.setup
    yield self
  end
end
