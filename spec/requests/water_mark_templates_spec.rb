require 'rails_helper'

RSpec.describe "WaterMarkTemplates", type: :request do
  describe "GET /water_mark_templates" do
    it "works! (now write some real specs)" do
      get water_mark_templates_path
      expect(response).to have_http_status(200)
    end
  end
end
