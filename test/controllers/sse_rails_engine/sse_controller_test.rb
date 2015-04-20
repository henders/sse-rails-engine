require_relative '../../test_helper'

describe SseRailsEngine::SseController do
  before do
    SseRailsEngine.instance_variable_set(:@manager, nil)
    @routes = SseRailsEngine::Engine.routes
    request.env['rack.hijack?'] = 1
  end

  it 'registers new connections' do
    get :connect
    assert_response :success
    response.headers['rack.hijack'].call(response.stream)
    SseRailsEngine.manager.connections.size.must_equal 1
  end

  it 'sends event to connection' do
    get :connect
    response.headers['rack.hijack'].call(response.stream)
    SseRailsEngine.manager.connections.size.must_equal 1
    ActionController::Live::SSE.any_instance.expects(:write).with('bar', event: 'foo').once
    SseRailsEngine.send_event('foo', 'bar')
  end
end
