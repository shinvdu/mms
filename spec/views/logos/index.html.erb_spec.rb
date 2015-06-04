require 'rails_helper'

RSpec.describe "logos/index", type: :view do
  before(:each) do
    assign(:logos, [
      Logo.create!(),
      Logo.create!()
    ])
  end

  it "renders a list of logos" do
    render
  end
end
