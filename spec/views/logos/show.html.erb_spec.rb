require 'rails_helper'

RSpec.describe "logos/show", type: :view do
  before(:each) do
    @logo = assign(:logo, Logo.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
