require 'rails_helper'

RSpec.describe "logos/new", type: :view do
  before(:each) do
    assign(:logo, Logo.new())
  end

  it "renders new logo form" do
    render

    assert_select "form[action=?][method=?]", logos_path, "post" do
    end
  end
end
