require_relative '../../test_helper'

describe SseRailsEngine::SseController do
  before do
    SseRailsEngine.instance_variable_set(:@manager, nil)
    @routes = SseRailsEngine::Engine.routes
  end

  it 'registers new connections' do
    SseRailsEngine.expects(:wait_for_disconnect).returns(true)
    get :connect
    assert_response :success
    SseRailsEngine.manager.connections.size.must_equal 1
  end

  it 'sends event to connection' do
    SseRailsEngine.expects(:wait_for_disconnect).returns(true)
    get :connect
    SseRailsEngine.manager.connections.size.must_equal 1
    ActionController::Live::SSE.any_instance.expects(:write).with('bar', event: 'foo').once
    SseRailsEngine.send_event('foo', 'bar')
  end
end
