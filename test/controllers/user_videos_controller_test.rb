require 'test_helper'

class UserVideosControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
