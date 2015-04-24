require 'test_helper'

class Advertise::ResourcesControllerTest < ActionController::TestCase
  setup do
    @advertise_resource = advertise_resources(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:advertise_resources)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create advertise_resource" do
    assert_difference('Advertise::Resource.count') do
      post :create, advertise_resource: { ad_type: @advertise_resource.ad_type, ad_word: @advertise_resource.ad_word, data: @advertise_resource.data, file_type: @advertise_resource.file_type, filesize: @advertise_resource.filesize, name: @advertise_resource.name, uri: @advertise_resource.uri, user_id: @advertise_resource.user_id }
    end

    assert_redirected_to advertise_resource_path(assigns(:advertise_resource))
  end

  test "should show advertise_resource" do
    get :show, id: @advertise_resource
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @advertise_resource
    assert_response :success
  end

  test "should update advertise_resource" do
    patch :update, id: @advertise_resource, advertise_resource: { ad_type: @advertise_resource.ad_type, ad_word: @advertise_resource.ad_word, data: @advertise_resource.data, file_type: @advertise_resource.file_type, filesize: @advertise_resource.filesize, name: @advertise_resource.name, uri: @advertise_resource.uri, user_id: @advertise_resource.user_id }
    assert_redirected_to advertise_resource_path(assigns(:advertise_resource))
  end

  test "should destroy advertise_resource" do
    assert_difference('Advertise::Resource.count', -1) do
      delete :destroy, id: @advertise_resource
    end

    assert_redirected_to advertise_resources_path
  end
end
