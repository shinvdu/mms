require 'test_helper'

class Advertise::StrategiesControllerTest < ActionController::TestCase
  setup do
    @advertise_strategy = advertise_strategies(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:advertise_strategies)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create advertise_strategy" do
    assert_difference('Advertise::Strategy.count') do
      post :create, advertise_strategy: { data: @advertise_strategy.data, end_ad: @advertise_strategy.end_ad, float_ad: @advertise_strategy.float_ad, front_ad: @advertise_strategy.front_ad, name: @advertise_strategy.name, pause_ad: @advertise_strategy.pause_ad, scroll_ad: @advertise_strategy.scroll_ad, user_id: @advertise_strategy.user_id }
    end

    assert_redirected_to advertise_strategy_path(assigns(:advertise_strategy))
  end

  test "should show advertise_strategy" do
    get :show, id: @advertise_strategy
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @advertise_strategy
    assert_response :success
  end

  test "should update advertise_strategy" do
    patch :update, id: @advertise_strategy, advertise_strategy: { data: @advertise_strategy.data, end_ad: @advertise_strategy.end_ad, float_ad: @advertise_strategy.float_ad, front_ad: @advertise_strategy.front_ad, name: @advertise_strategy.name, pause_ad: @advertise_strategy.pause_ad, scroll_ad: @advertise_strategy.scroll_ad, user_id: @advertise_strategy.user_id }
    assert_redirected_to advertise_strategy_path(assigns(:advertise_strategy))
  end

  test "should destroy advertise_strategy" do
    assert_difference('Advertise::Strategy.count', -1) do
      delete :destroy, id: @advertise_strategy
    end

    assert_redirected_to advertise_strategies_path
  end
end
