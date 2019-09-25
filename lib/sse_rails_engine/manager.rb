# frozen_string_literal: true

module SseRailsEngine
  # This class provides the ability to track SSE connections and broadcast events
  # to all connected clients from anywhere in your Rails app.
  #
  # Example Usage:
  #
  #   class MyController < ActionController::Base
  #     def do_stuff
  #       SseRailsEngine.send_event('event name', 'any ruby object or string for data')
  #     end
  #   end
  #
  # Note: SSEs are not currently supported by IE.
  class Manager
    RackHijackUnsupported = Class.new RuntimeError

    attr_reader :connections, :heartbeat_thread

    HEARTBEAT_EVENT = 'heartbeat'

    def initialize
      @mutex = Mutex.new
      @connections = ThreadSafe::Cache.new
    end

    def register(env)
      if env['rack.hijack']
        env['rack.hijack'].call
        socket = env['rack.hijack_io']
        # Perform full hijack of socket (http://old.blog.phusion.nl/2013/01/23/the-new-rack-socket-hijacking-api/)
        open_connection(socket, env)
      else
        raise RackHijackUnsupported, 'This Rack server does not support hijacking, ensure you are using >= v1.5 of Rack'
      end
    end

    def send_event(name, data = '')
      @mutex.synchronize do
        @connections.each_pair do |stream, connection|
          begin
            connection.write(name, data)
          rescue StandardError => ex
            Rails.logger.debug "SSE Client disconnected: #{stream} - #{ex.message}"
            close_connection(stream)
          end
        end
      end
    end

    def open_connection(io, env)
      @connections[io] = Connection.new(io, env)
      Rails.logger.debug "New SSE Client connected: #{io} - #{@connections[io].channels}"
      start_heartbeats
    end

    def call(env)
      register(env)
      [-1, {}, []]
    ensure
      ActiveRecord::Base.clear_active_connections! if defined?(ActiveRecord)
    end

    private

    def close_connection(stream)
      if connection = @connections.delete(stream)
        connection.stream.close
      end
    end

    def start_heartbeats
      @heartbeat_thread ||= Thread.new do
        Rails.logger.debug 'Starting SSE heartbeat thread'
        loop do
          sleep SseRailsEngine.heartbeat_interval
          send_event(HEARTBEAT_EVENT)
          break unless @connections.present?
        end

        Rails.logger.debug 'Terminating SSE heartbeat thread'
        @heartbeat_thread = nil
      end
    end
  end
end
