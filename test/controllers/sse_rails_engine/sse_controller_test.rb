require_relative '../../test_helper'

module SseRailsEngine
  describe SseController do
    it 'Connects' do
      get :connect
      assert_response :success
    end
  end
end
