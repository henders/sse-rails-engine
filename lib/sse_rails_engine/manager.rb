module SseRailsEngine
  def self.manager
    @manager ||= Manager.new
  end

  def self.wait_for_disconnect(response)
    loop do
      sleep 3
      break unless manager.registered?(response)
    end
  end

  def self.send_event(name, data)
    manager.send_event(name, data)
  end

  class Manager
    attr_reader :connections

    def initialize
      @mutex = Mutex.new
      @connections = {}
      start_heartbeats
    end

    def register(response)
      ActiveRecord::Base.clear_active_connections! if defined?(ActiveRecord)
      response.headers['Content-Type'] = 'text/event-stream'
      response.headers['Cache-Control'] = 'no-cache'
      @mutex.synchronize do
        @connections[response.stream] = ActionController::Live::SSE.new(response.stream)
      end
    end

    def registered?(response)
      @mutex.synchronize do
        @connections[response.stream] ? true : false
      end
    end

    def unregister(response)
      @mutex.synchronize do
        close_connection(response.stream)
      end
    end

    def send_event(name, data)
      @mutex.synchronize do
        @connections.dup.each do |stream, sse|
          begin
            sse.write(data, event: name)
          rescue ActionController::Live::ClientDisconnected
            close_connection(stream)
          rescue => ex
            Rails.logger.error "Failed to send event to SSE: #{stream} (#{name}, #{data} - #{ex.message}"
          end
        end
      end
    end

    private

    def close_connection(stream)
      return if @connections[stream].nil?
      @connections[stream].close
      @connections.delete(stream)
      stream.close unless stream.closed?
    end

    def heartbeat
      send_event('heartbeat', '')
    end

    def start_heartbeats
      Thread.new do
        loop do
          sleep 5
          heartbeat
        end
      end
    end
  end
end
