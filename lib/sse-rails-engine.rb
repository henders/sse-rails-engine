# frozen_string_literal: true

require 'sse_rails_engine/engine'
require 'sse_rails_engine/connection'
require 'sse_rails_engine/manager'

module SseRailsEngine
  mattr_accessor :heartbeat_interval, :access_control_allow_origin

  self.heartbeat_interval = 5.seconds

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
