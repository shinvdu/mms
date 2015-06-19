require 'rails_helper'

RSpec.describe "logos/edit", type: :view do
  before(:each) do
    @logo = assign(:logo, Logo.create!())
  end

  it "renders the edit logo form" do
    render

    assert_select "form[action=?][method=?]", logo_path(@logo), "post" do
    end
  end
end
