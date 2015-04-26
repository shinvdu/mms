require 'test_helper'

class TranscodingStrategyRelationshipsControllerTest < ActionController::TestCase
  setup do
    @transcoding_strategy_relationship = transcoding_strategy_relationships(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:transcoding_strategy_relationships)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create transcoding_strategy_relationship" do
    assert_difference('TranscodingStrategyRelationship.count') do
      post :create, transcoding_strategy_relationship: { transcoding_id: @transcoding_strategy_relationship.transcoding_id, transcoding_strategy_id: @transcoding_strategy_relationship.transcoding_strategy_id, user_id: @transcoding_strategy_relationship.user_id }
    end

    assert_redirected_to transcoding_strategy_relationship_path(assigns(:transcoding_strategy_relationship))
  end

  test "should show transcoding_strategy_relationship" do
    get :show, id: @transcoding_strategy_relationship
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @transcoding_strategy_relationship
    assert_response :success
  end

  test "should update transcoding_strategy_relationship" do
    patch :update, id: @transcoding_strategy_relationship, transcoding_strategy_relationship: { transcoding_id: @transcoding_strategy_relationship.transcoding_id, transcoding_strategy_id: @transcoding_strategy_relationship.transcoding_strategy_id, user_id: @transcoding_strategy_relationship.user_id }
    assert_redirected_to transcoding_strategy_relationship_path(assigns(:transcoding_strategy_relationship))
  end

  test "should destroy transcoding_strategy_relationship" do
    assert_difference('TranscodingStrategyRelationship.count', -1) do
      delete :destroy, id: @transcoding_strategy_relationship
    end

    assert_redirected_to transcoding_strategy_relationships_path
  end
end
