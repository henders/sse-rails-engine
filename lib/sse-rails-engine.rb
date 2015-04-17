require 'sse_rails_engine/engine'
require 'sse_rails_engine/manager'

module SseRailsEngine
  mattr_accessor :disconnect_wait_time
  mattr_accessor :heartbeat_interval

  @@disconnect_wait_time = 3.seconds
  @@heartbeat_interval = 5.seconds

  def self.manager
    @manager ||= Manager.new
  end

  def self.wait_for_disconnect(response)
    loop do
      sleep disconnect_wait_time
      break unless manager.registered?(response)
    end
    true
  end

  def self.send_event(name, data)
    manager.send_event(name, data)
  end

  def self.setup
    yield self
  end
end
