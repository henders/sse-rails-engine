require_relative '../../test_helper'

describe SseRailsEngine::Manager do
  let(:manager) { SseRailsEngine.manager }
  let(:env1) { {'rack.hijack?' => true, 'rack.hijack' => ->() {}, 'rack.hijack_io' => StringIO.new} }
  let(:env2) { {'rack.hijack?' => true, 'rack.hijack' => ->() {}, 'rack.hijack_io' => StringIO.new} }

  before do
    SseRailsEngine.instance_variable_set(:@manager, nil)
    SseRailsEngine::Manager.stubs(:start_heartbeats).returns(true)
  end

  it 'ensures rack supports hijacking' do
    env1['rack.hijack'] = nil
    assert_raises(SseRailsEngine::Manager::RackHijackUnsupported) { manager.register(env1) }
  end

  it 'registers new response streams' do
    manager.connections.size.must_equal 0
    manager.register(env1)
    manager.connections.size.must_equal 1
  end

  it 'does not register new response stream' do
    manager.connections.size.must_equal 0
  end

  it 'closes connection when client disconnects' do
    ActionController::Live::SSE.any_instance.stubs(:write).raises(IOError)

    manager.register(env1)
    manager.connections.size.must_equal 1
    manager.send_event('foo', 'bar')
    manager.connections.size.must_equal 0
  end

  it 'closes connection when failed sending event to client' do
    ActionController::Live::SSE.any_instance.stubs(:write).raises(IOError)

    manager.register(env1)
    manager.connections.size.must_equal 1
    manager.send_event('foo', 'bar')
    manager.connections.size.must_equal 0
  end

  it 'writes string event to stream' do
    manager.register(env1)
    manager.send_event('foo', 'bar')
    env1['rack.hijack_io'].string.must_equal(SseRailsEngine::Connection.sse_header + "event: foo\ndata: bar\n\n")
  end

  it 'writes event object to stream' do
    manager.register(env1)
    manager.send_event('foo', a: 123, 'b' => 'abc', c: { foo: 'bar' })
    env1['rack.hijack_io'].string.must_equal(
      SseRailsEngine::Connection.sse_header +
      "event: foo\ndata: {\"a\":123,\"b\":\"abc\",\"c\":{\"foo\":\"bar\"}}\n\n"
    )
  end

  it 'writes minimum headers to rack middleware' do
    manager.call(env1).must_equal [-1, {}, []]
  end

  it 'ensures heartbeat is sent' do
    SseRailsEngine.stubs(:heartbeat_interval).returns(0, 5)
    SseRailsEngine::Manager.unstub(:start_heartbeats)
    SseRailsEngine::Manager.any_instance.expects(:send_event).once
    SseRailsEngine::Manager.new
    sleep 0.2
  end

  it 'sends events to connections that register for that channel' do
    env1['QUERY_STRING'] = 'channels=foo,bar'
    manager.register(env1)
    manager.send_event('foo')
    env1['rack.hijack_io'].string.must_equal(
      SseRailsEngine::Connection.sse_header + "event: foo\ndata: \n\n", 'env1 should have received event')
  end

  it 'does not send events to clients that didnt register for them' do
    env1['QUERY_STRING'] = 'channels=foo,bar'
    manager.register(env1)
    manager.send_event('test')
    env1['rack.hijack_io'].string.must_equal(
      SseRailsEngine::Connection.sse_header, 'env2 should not have received event')
  end

  it 'filters msgs depending on channels requested' do
    env2['QUERY_STRING'] = 'channels=foo,bar'
    manager.register(env1)
    manager.register(env2)
    manager.send_event('test')
    env1['rack.hijack_io'].string.must_equal(
      SseRailsEngine::Connection.sse_header + "event: test\ndata: \n\n", 'env1 should have received event')
    env2['rack.hijack_io'].string.must_equal(
      SseRailsEngine::Connection.sse_header, 'env2 should not have received event')
  end
end
