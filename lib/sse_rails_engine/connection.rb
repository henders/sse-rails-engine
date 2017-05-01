# frozen_string_literal: true

module SseRailsEngine
  class Connection
    attr_accessor :stream, :channels
    cattr_accessor :sse_header

    def initialize(io, env)
      @socket = io
      @socket.write(sse_header)
      @socket.flush
      @stream = ActionController::Live::SSE.new(io)
      @channels = requested_channels(env)
    end

    def write(name, data)
      return if filtered?(name)
      @stream.write(data, event: name)
      @socket.flush
    end

    private

    def filtered?(channel)
      return false if @channels.empty? || channel == Manager::HEARTBEAT_EVENT
      !@channels.include?(channel)
    end

    def requested_channels(env)
      Rack::Utils.parse_query(env['QUERY_STRING']).fetch('channels', []).split(',').flatten
    end
  end
end
