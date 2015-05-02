require 'test_helper'

class TranscodingsControllerTest < ActionController::TestCase
  setup do
    @transcoding = transcodings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:transcodings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create transcoding" do
    assert_difference('Transcoding.count') do
      post :create, transcoding: { audio_code_rate: @transcoding.audio_code_rate, audio_encode: @transcoding.audio_encode, audio_sample_rate: @transcoding.audio_sample_rate, data: @transcoding.data, height: @transcoding.height, name: @transcoding.name, output_format: @transcoding.output_format, quality: @transcoding.quality, speed: @transcoding.speed, user_id: @transcoding.user_id, width: @transcoding.width }
    end

    assert_redirected_to transcoding_path(assigns(:transcoding))
  end

  test "should show transcoding" do
    get :show, id: @transcoding
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @transcoding
    assert_response :success
  end

  test "should update transcoding" do
    patch :update, id: @transcoding, transcoding: { audio_code_rate: @transcoding.audio_code_rate, audio_encode: @transcoding.audio_encode, audio_sample_rate: @transcoding.audio_sample_rate, data: @transcoding.data, height: @transcoding.height, name: @transcoding.name, output_format: @transcoding.output_format, quality: @transcoding.quality, speed: @transcoding.speed, user_id: @transcoding.user_id, width: @transcoding.width }
    assert_redirected_to transcoding_path(assigns(:transcoding))
  end

  test "should destroy transcoding" do
    assert_difference('Transcoding.count', -1) do
      delete :destroy, id: @transcoding
    end

    assert_redirected_to transcodings_path
  end
end
