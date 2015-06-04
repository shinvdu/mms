require 'rails_helper'

RSpec.describe "water_mark_templates/edit", type: :view do
  before(:each) do
    @water_mark_template = assign(:water_mark_template, WaterMarkTemplate.create!(
      :owner_id => 1,
      :creator_id => 1,
      :name => "MyString",
      :width => 1,
      :height => 1,
      :refer_pos => "MyString",
      :text => "MyString",
      :img => "MyString"
    ))
  end

  it "renders the edit water_mark_template form" do
    render

    assert_select "form[action=?][method=?]", water_mark_template_path(@water_mark_template), "post" do

      assert_select "input#water_mark_template_owner_id[name=?]", "water_mark_template[owner_id]"

      assert_select "input#water_mark_template_creator_id[name=?]", "water_mark_template[creator_id]"

      assert_select "input#water_mark_template_name[name=?]", "water_mark_template[name]"

      assert_select "input#water_mark_template_width[name=?]", "water_mark_template[width]"

      assert_select "input#water_mark_template_height[name=?]", "water_mark_template[height]"

      assert_select "input#water_mark_template_refer_pos[name=?]", "water_mark_template[refer_pos]"

      assert_select "input#water_mark_template_text[name=?]", "water_mark_template[text]"

      assert_select "input#water_mark_template_img[name=?]", "water_mark_template[img]"
    end
  end
end
