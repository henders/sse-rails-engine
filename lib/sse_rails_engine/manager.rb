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
      @connections = {}
      start_heartbeats
      @connect_listeners = []
      @disconnect_listeners = []
    end

    def register(env)
      if env['rack.hijack']
        env['rack.hijack'].call
        socket = env['rack.hijack_io']
        # Perform full hijack of socket (http://old.blog.phusion.nl/2013/01/23/the-new-rack-socket-hijacking-api/)
        open_connection(socket, env)
        connect_callback(env)
      else
        fail RackHijackUnsupported, 'This Rack server does not support hijacking, ensure you are using >= v1.5 of Rack'
      end
    end

    def send_event(name, data = '')
      @mutex.synchronize do
        @connections.dup.each do |stream, connection|
          begin
            connection.write(name, data)
          rescue => ex
            Rails.logger.debug "SSE Client disconnected: #{stream} - #{ex.message}"
            close_connection(stream)
          end
        end
      end
    end

    def open_connection(io, env)
      @mutex.synchronize do
        @connections[io] = Connection.new(io, env)
        Rails.logger.debug "New SSE Client connected: #{io} - #{@connections[io].channels}"
      end
    end

    def call(env)
      register(env)
      [-1, {}, []]
    end

    def on_connect(&block)
      @connect_listeners << block
    end

    def on_disconnect(&block)
      @disconnect_listeners << block
    end

    private

    def close_connection(stream)
      return if @connections[stream].nil?
      @connections[stream].stream.close
      disconnect_callback(@connections[stream].env)
      @connections.delete(stream)
    end

    def connect_callback(env)
      @connect_listeners.each { |listener| listener.call(env) }
    end

    def disconnect_callback(env)
      @disconnect_listeners.each { |listener| listener.call(env) }
    end

    def start_heartbeats
      Rails.logger.debug 'Starting SSE heartbeat thread!'
      @heartbeat_thread = Thread.new do
        loop do
          sleep SseRailsEngine.heartbeat_interval
          send_event(HEARTBEAT_EVENT)
        end
      end
    end
  end
end
