require 'rails_helper'

RSpec.describe "water_mark_templates/show", type: :view do
  before(:each) do
    @water_mark_template = assign(:water_mark_template, WaterMarkTemplate.create!(
      :owner_id => 1,
      :creator_id => 2,
      :name => "Name",
      :width => 3,
      :height => 4,
      :refer_pos => "Refer Pos",
      :text => "Text",
      :img => "Img"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/Refer Pos/)
    expect(rendered).to match(/Text/)
    expect(rendered).to match(/Img/)
  end
end
