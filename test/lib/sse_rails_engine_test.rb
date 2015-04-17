require_relative '../test_helper'

describe SseRailsEngine do
  before do
    SseRailsEngine.disconnect_wait_time = 3.seconds
    SseRailsEngine.heartbeat_interval = 5.seconds
  end

  it "should be a module" do
    assert_kind_of Module, SseRailsEngine
  end

  it 'should have module singleton instance' do
    SseRailsEngine.manager.must_equal SseRailsEngine.manager
  end

  it 'should have default config values' do
    SseRailsEngine.disconnect_wait_time.must_equal 3.seconds
    SseRailsEngine.heartbeat_interval.must_equal 5.seconds
  end

  it 'allows usage of setup block' do
    SseRailsEngine.setup do |config|
      config.disconnect_wait_time.must_equal 3.seconds
      config.heartbeat_interval.must_equal 5.seconds
    end
  end

  it 'allows config override' do
    SseRailsEngine.setup do |config|
      config.disconnect_wait_time = 99.hours
      config.heartbeat_interval = 1.minute
    end
    SseRailsEngine.disconnect_wait_time.must_equal 99.hours
    SseRailsEngine.heartbeat_interval.must_equal 1.minute
  end

  it 'disconnects without a registry' do
    response = Hashie::Mash.new(stream: StringIO.new, headers: {})
    SseRailsEngine.disconnect_wait_time = 0.1
    SseRailsEngine.wait_for_disconnect(response).must_equal true
  end

  it 'disconnects after registry deletion' do
    SseRailsEngine.manager.expects(:registered?).times(3).returns(true, true, false)
    response = Hashie::Mash.new(stream: StringIO.new, headers: {})
    SseRailsEngine.disconnect_wait_time = 0.1
    SseRailsEngine.wait_for_disconnect(response).must_equal true
  end
end
