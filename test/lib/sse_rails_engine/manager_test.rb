require_relative '../../test_helper'

describe SseRailsEngine::Manager do
  let(:manager) { SseRailsEngine::manager }
  let(:env) {
    Hashie::Mash.new('rack.hijack?' => true,
                     'rack.hijack' => ->() { },
                     'rack.hijack_io' => StringIO.new)
  }

  before do
    SseRailsEngine.instance_variable_set(:@manager, nil)
    SseRailsEngine::Manager.stubs(:start_heartbeats).returns(true)
  end

  it 'registers new response streams' do
    manager.connections.size.must_equal 0
    manager.register(env)
    manager.connections.size.must_equal 1
  end

  it 'does not register new response stream' do
    manager.connections.size.must_equal 0
  end

  it 'closes connection when client disconnects' do
    ActionController::Live::SSE.any_instance.stubs(:write).raises(IOError)

    manager.register(env)
    manager.connections.size.must_equal 1
    manager.send_event('foo', 'bar')
    manager.connections.size.must_equal 0
  end

  it 'writes string event to stream' do
    manager.register(env)
    manager.send_event('foo', 'bar')
    env['rack.hijack_io'].string.must_equal(SseRailsEngine::Manager::SSE_HEADER + "event: foo\ndata: bar\n\n")
  end

  it 'writes event object to stream' do
    manager.register(env)
    manager.send_event('foo', { a: 123, 'b' => 'abc', c: { foo: 'bar' } })
    env['rack.hijack_io'].string.must_equal(SseRailsEngine::Manager::SSE_HEADER + "event: foo\ndata: {\"a\":123,\"b\":\"abc\",\"c\":{\"foo\":\"bar\"}}\n\n")
  end
end
