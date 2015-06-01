require 'rails_helper'

RSpec.describe VideoController, type: :controller do

  describe "GET #show" do
    it "returns http success" do
      video_group = FactoryGirl.create(:video_product_group)
      video_detail = FactoryGirl.create(:video_detail)
      video_product = FactoryGirl.create(:video_product)
      get :show, :id =>  video_group.id
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #iframe" do
    it "returns http success" do
      get :iframe, :id =>  234
      expect(response).to have_http_status(:success)
    end
  end

end
