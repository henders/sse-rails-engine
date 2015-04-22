require_relative '../../test_helper'

describe SseRailsEngine::Manager do
  let(:manager) { SseRailsEngine.manager }
  let(:env) do
    Hashie::Mash.new('rack.hijack?' => true,
                     'rack.hijack' => ->() {},
                     'rack.hijack_io' => StringIO.new)
  end

  before do
    SseRailsEngine.instance_variable_set(:@manager, nil)
    SseRailsEngine::Manager.stubs(:start_heartbeats).returns(true)
  end

  it 'ensures rack supports hijacking' do
    env['rack.hijack'] = nil
    assert_raises(SseRailsEngine::Manager::RackHijackUnsupported) { manager.register(env) }
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

  it 'closes connection when failed sending event to client' do
    ActionController::Live::SSE.any_instance.stubs(:write).raises(RuntimeError)

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
    manager.send_event('foo', a: 123, 'b' => 'abc', c: { foo: 'bar' })
    env['rack.hijack_io'].string.must_equal(
      SseRailsEngine::Manager::SSE_HEADER + "event: foo\ndata: {\"a\":123,\"b\":\"abc\",\"c\":{\"foo\":\"bar\"}}\n\n")
  end

  it 'writes minimum headers to rack middleware' do
    manager.call(env).must_equal [-1, {}, []]
  end

  it 'ensures heartbeat is sent' do
    SseRailsEngine.stubs(:heartbeat_interval).returns(0, 5)
    SseRailsEngine::Manager.unstub(:start_heartbeats)
    SseRailsEngine::Manager.any_instance.expects(:send_event).once
    SseRailsEngine::Manager.new
    sleep 0.2
  end
end
