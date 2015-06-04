require "rails_helper"

RSpec.describe LogosController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/logos").to route_to("logos#index")
    end

    it "routes to #new" do
      expect(:get => "/logos/new").to route_to("logos#new")
    end

    it "routes to #show" do
      expect(:get => "/logos/1").to route_to("logos#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/logos/1/edit").to route_to("logos#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/logos").to route_to("logos#create")
    end

    it "routes to #update" do
      expect(:put => "/logos/1").to route_to("logos#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/logos/1").to route_to("logos#destroy", :id => "1")
    end

  end
end
