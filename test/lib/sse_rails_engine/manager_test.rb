require_relative '../../test_helper'

describe SseRailsEngine::Manager do
  let(:response) { Hashie::Mash.new(stream: StringIO.new, headers: {}) }
  let(:manager) { SseRailsEngine.manager }

  it 'should only instantiate 1 manager' do
    manager.must_equal SseRailsEngine.manager
  end

  it 'registers new response streams' do
    manager.register(response)
    manager.registered?(response).must_equal true
  end

  it 'does not register new response stream' do
    manager.registered?(response).must_equal false
  end

  it 'closes connection when client disconnects' do
    ActionController::Live::SSE.any_instance.stubs(:write).raises(ActionController::Live::ClientDisconnected)

    manager.register(response)
    manager.registered?(response).must_equal true
    manager.send_event('foo', 'bar')
    manager.registered?(response).must_equal false
  end

  it 'writes string event to stream' do
    manager.register(response)
    manager.send_event('foo', 'bar')
    response.stream.string.must_equal "event: foo\ndata: bar\n\n"
  end

  it 'writes event object to stream' do
    manager.register(response)
    manager.send_event('foo', { a: 123, 'b' => 'abc', c: { foo: 'bar' } })
    response.stream.string.must_equal "event: foo\ndata: {\"a\":123,\"b\":\"abc\",\"c\":{\"foo\":\"bar\"}}\n\n"
  end
end
