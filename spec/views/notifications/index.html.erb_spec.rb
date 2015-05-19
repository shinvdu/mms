require 'rails_helper'

RSpec.describe "notifications/index", type: :view do
  before(:each) do
    assign(:notifications, [
      Notification.create!(
        :user_id => 1,
        :is_read => false,
        :title => "Title",
        :target_id => 2,
        :target_type => "Target Type"
      ),
      Notification.create!(
        :user_id => 1,
        :is_read => false,
        :title => "Title",
        :target_id => 2,
        :target_type => "Target Type"
      )
    ])
  end

  it "renders a list of notifications" do
    render
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Target Type".to_s, :count => 2
  end
end
