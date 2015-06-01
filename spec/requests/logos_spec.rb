require 'rails_helper'

RSpec.describe "Logos", type: :request do
  describe "GET /logos" do
    it "works! (now write some real specs)" do
      get logos_path
      expect(response).to have_http_status(200)
    end
  end
end
