require_relative '../../test_helper'

describe SseRailsEngine::Manager do
  let(:response) { Hashie::Mash.new(stream: StringIO.new, headers: {}) }
  let(:manager) { SseRailsEngine::manager }

  before { SseRailsEngine.instance_variable_set(:@manager, nil) }

  it 'registers new response streams' do
    manager.connections.size.must_equal 0
    manager.register(response)
    response.headers['rack.hijack'].call(response.stream)
    manager.connections.size.must_equal 1
  end

  it 'does not register new response stream' do
    manager.connections.size.must_equal 0
  end

  it 'closes connection when client disconnects' do
    ActionController::Live::SSE.any_instance.stubs(:write).raises(IOError)

    manager.register(response)
    response.headers['rack.hijack'].call(response.stream)
    manager.connections.size.must_equal 1
    manager.send_event('foo', 'bar')
    manager.connections.size.must_equal 0
  end

  it 'writes string event to stream' do
    manager.register(response)
    response.headers['rack.hijack'].call(response.stream)
    manager.send_event('foo', 'bar')
    response.stream.string.must_equal "event: foo\ndata: bar\n\n"
  end

  it 'writes event object to stream' do
    manager.register(response)
    response.headers['rack.hijack'].call(response.stream)
    manager.send_event('foo', { a: 123, 'b' => 'abc', c: { foo: 'bar' } })
    response.stream.string.must_equal "event: foo\ndata: {\"a\":123,\"b\":\"abc\",\"c\":{\"foo\":\"bar\"}}\n\n"
  end
end
