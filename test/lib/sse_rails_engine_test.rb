require_relative '../test_helper'

describe SseRailsEngine do
  before do
    SseRailsEngine.heartbeat_interval = 5.seconds
  end

  it 'should be a module' do
    assert_kind_of Module, SseRailsEngine
  end

  it 'should have module singleton instance' do
    SseRailsEngine.manager.must_equal SseRailsEngine.manager
  end

  it 'should have default config values' do
    SseRailsEngine.heartbeat_interval.must_equal 5.seconds
  end

  it 'allows usage of setup block' do
    SseRailsEngine.setup do |config|
      config.heartbeat_interval.must_equal 5.seconds
    end
  end

  it 'allows config override' do
    SseRailsEngine.setup do |config|
      config.heartbeat_interval = 1.minute
    end
    SseRailsEngine.heartbeat_interval.must_equal 1.minute
  end
end
