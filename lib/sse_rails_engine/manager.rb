module SseRailsEngine
  class Manager
    RackHijackUnsupported = Class.new RuntimeError

    attr_reader :connections, :heartbeat_thread

    SSE_HEADER = ["HTTP/1.1 200 OK\r\n",
      "Content-Type: text/event-stream\r\n",
      "Cache-Control: no-cache, no-store\r\n",
      "Connection: close\r\n",
      "\r\n"].join.freeze

    def initialize
      @mutex = Mutex.new
      @connections = {}
      start_heartbeats
    end

    def register(env)
      if env['rack.hijack']
        env['rack.hijack'].call
        socket = env['rack.hijack_io']
        # Perform full hijack of socket (http://old.blog.phusion.nl/2013/01/23/the-new-rack-socket-hijacking-api/)
        SseRailsEngine.manager.open_connection(socket)
      else
        raise RackHijackUnsupported, 'This Rack server does not support hijacking, ensure you are using >= v1.5 of Rack'
      end
    end

    def send_event(name, data)
      @mutex.synchronize do
        @connections.dup.each do |stream, sse|
          begin
            sse.write(data, event: name)
            stream.flush
          rescue IOError, Errno::EPIPE, Errno::ETIMEDOUT
            Rails.logger.debug "SSE Client disconnected: #{stream}"
            close_connection(stream)
          rescue => ex
            Rails.logger.error "Failed to send event to SSE: #{stream} (#{name}, #{data} - #{ex.message} (#{ex.class}"
            close_connection(stream)
          end
        end
      end
    end

    def open_connection(io)
      Rails.logger.debug "New SSE Client connected: #{io}"
      io.write(SSE_HEADER)
      @mutex.synchronize do
        @connections[io] = ActionController::Live::SSE.new(io)
      end
    end

    def call(env)
      SseRailsEngine.manager.register(env)
      [ -1, {}, []]
    end

    private

    def close_connection(stream)
      return if @connections[stream].nil?
      @connections[stream].close
      @connections.delete(stream)
    end

    def start_heartbeats
      Rails.logger.debug 'Starting SSE heartbeat thread!'
      @heartbeat_thread = Thread.new do
        loop do
          sleep SseRailsEngine.heartbeat_interval
          send_event('heartbeat', '')
        end
      end
    end
  end
end
