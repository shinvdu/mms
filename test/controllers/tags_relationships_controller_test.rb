require 'test_helper'

class TagsRelationshipsControllerTest < ActionController::TestCase
  setup do
    @tags_relationship = tags_relationships(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tags_relationships)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tags_relationship" do
    assert_difference('TagsRelationship.count') do
      post :create, tags_relationship: { tag_id: @tags_relationship.tag_id, user_video_id: @tags_relationship.user_video_id }
    end

    assert_redirected_to tags_relationship_path(assigns(:tags_relationship))
  end

  test "should show tags_relationship" do
    get :show, id: @tags_relationship
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tags_relationship
    assert_response :success
  end

  test "should update tags_relationship" do
    patch :update, id: @tags_relationship, tags_relationship: { tag_id: @tags_relationship.tag_id, user_video_id: @tags_relationship.user_video_id }
    assert_redirected_to tags_relationship_path(assigns(:tags_relationship))
  end

  test "should destroy tags_relationship" do
    assert_difference('TagsRelationship.count', -1) do
      delete :destroy, id: @tags_relationship
    end

    assert_redirected_to tags_relationships_path
  end
end
