require 'rails_helper'

RSpec.describe VideoController, type: :controller do

  describe "GET #show" do
    it "returns http success" do
      video_group = FactoryGirl.create(:video_product_group)
      video_detail_1 = FactoryGirl.create(:video_detail)
      transcoding_1 = FactoryGirl.create(:transcoding)
      video_product_1 = FactoryGirl.create(:video_product, video_detail: video_detail_1, video_product_group: video_group, transcoding: transcoding_1)
      video_detail_2 = FactoryGirl.create(:video_detail)
      transcoding_2 = FactoryGirl.create(:transcoding)
      video_product_2 = FactoryGirl.create(:video_product, video_detail: video_detail_2, video_product_group: video_group, transcoding: transcoding_2)
      get :show, :id =>  video_group.show_id
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
