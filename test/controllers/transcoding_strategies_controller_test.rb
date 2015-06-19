require 'test_helper'

class TranscodingStrategiesControllerTest < ActionController::TestCase
  setup do
    @transcoding_strategy = transcoding_strategies(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:transcoding_strategies)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create transcoding_strategy" do
    assert_difference('TranscodingStrategy.count') do
      post :create, transcoding_strategy: { data: @transcoding_strategy.data, name: @transcoding_strategy.name, note: @transcoding_strategy.note, user_id: @transcoding_strategy.user_id }
    end

    assert_redirected_to transcoding_strategy_path(assigns(:transcoding_strategy))
  end

  test "should show transcoding_strategy" do
    get :show, id: @transcoding_strategy
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @transcoding_strategy
    assert_response :success
  end

  test "should update transcoding_strategy" do
    patch :update, id: @transcoding_strategy, transcoding_strategy: { data: @transcoding_strategy.data, name: @transcoding_strategy.name, note: @transcoding_strategy.note, user_id: @transcoding_strategy.user_id }
    assert_redirected_to transcoding_strategy_path(assigns(:transcoding_strategy))
  end

  test "should destroy transcoding_strategy" do
    assert_difference('TranscodingStrategy.count', -1) do
      delete :destroy, id: @transcoding_strategy
    end

    assert_redirected_to transcoding_strategies_path
  end
end
