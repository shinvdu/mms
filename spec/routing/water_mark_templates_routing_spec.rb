require "rails_helper"

RSpec.describe WaterMarkTemplatesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/water_mark_templates").to route_to("water_mark_templates#index")
    end

    it "routes to #new" do
      expect(:get => "/water_mark_templates/new").to route_to("water_mark_templates#new")
    end

    it "routes to #show" do
      expect(:get => "/water_mark_templates/1").to route_to("water_mark_templates#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/water_mark_templates/1/edit").to route_to("water_mark_templates#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/water_mark_templates").to route_to("water_mark_templates#create")
    end

    it "routes to #update" do
      expect(:put => "/water_mark_templates/1").to route_to("water_mark_templates#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/water_mark_templates/1").to route_to("water_mark_templates#destroy", :id => "1")
    end

  end
end
