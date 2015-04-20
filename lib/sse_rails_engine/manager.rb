module SseRailsEngine
  class Manager
    attr_reader :connections

    def initialize
      @mutex = Mutex.new
      @connections = {}
      start_heartbeats
    end

    def register(response)
      response.headers['Content-Type'] = 'text/event-stream'
      response.headers['Cache-Control'] = 'no-cache'
      # Perform partial hijack of socket (http://old.blog.phusion.nl/2013/01/23/the-new-rack-socket-hijacking-api/)
      response.headers['rack.hijack'] = ->(io) { SseRailsEngine.manager.open_connection(io) }
    end

    def send_event(name, data)
      @mutex.synchronize do
        @connections.dup.each do |stream, sse|
          begin
            sse.write(data, event: name)
          rescue IOError, Errno::EPIPE, Errno::ETIMEDOUT
            Rails.logger.debug "SSE Client disconnected: #{stream}"
            close_connection(stream)
          rescue => ex
            Rails.logger.error "Failed to send event to SSE: #{stream} (#{name}, #{data} - #{ex.message} (#{ex.class}"
          end
        end
      end
    end

    def open_connection(io)
      Rails.logger.debug "New SSE Client connected: #{io}"
      @mutex.synchronize do
        @connections[io] = ActionController::Live::SSE.new(io)
      end
    end

    private

    def close_connection(stream)
      return if @connections[stream].nil?
      @connections[stream].close
      @connections.delete(stream)
    end

    def start_heartbeats
      Rails.logger.debug 'Starting SSE heartbeat thread!!!!!'
      Thread.new do
        loop do
          sleep SseRailsEngine.heartbeat_interval
          send_event('heartbeat', '')
        end
      end
    end
  end
end
