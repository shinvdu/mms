require 'rails_helper'

RSpec.describe HomeController, type: :controller do

  # before(:each) do #每次请求之前都先登录，不然会被devise拒绝

  # 	login_user

  # end
  login_user

  describe "GET index" do

    it "shoule be successful" do

      get 'index'

      expect(response).to be_success

    end

  end

end
