require 'rails_helper'

RSpec.describe "water_mark_templates/index", type: :view do
  before(:each) do
    assign(:water_mark_templates, [
      WaterMarkTemplate.create!(
        :owner_id => 1,
        :creator_id => 2,
        :name => "Name",
        :width => 3,
        :height => 4,
        :refer_pos => "Refer Pos",
        :text => "Text",
        :img => "Img"
      ),
      WaterMarkTemplate.create!(
        :owner_id => 1,
        :creator_id => 2,
        :name => "Name",
        :width => 3,
        :height => 4,
        :refer_pos => "Refer Pos",
        :text => "Text",
        :img => "Img"
      )
    ])
  end

  it "renders a list of water_mark_templates" do
    render
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => "Refer Pos".to_s, :count => 2
    assert_select "tr>td", :text => "Text".to_s, :count => 2
    assert_select "tr>td", :text => "Img".to_s, :count => 2
  end
end
