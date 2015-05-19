require 'rails_helper'

RSpec.describe "notifications/new", type: :view do
  before(:each) do
    assign(:notification, Notification.new(
      :user_id => 1,
      :is_read => false,
      :title => "MyString",
      :target_id => 1,
      :target_type => "MyString"
    ))
  end

  it "renders new notification form" do
    render

    assert_select "form[action=?][method=?]", notifications_path, "post" do

      assert_select "input#notification_user_id[name=?]", "notification[user_id]"

      assert_select "input#notification_is_read[name=?]", "notification[is_read]"

      assert_select "input#notification_title[name=?]", "notification[title]"

      assert_select "input#notification_target_id[name=?]", "notification[target_id]"

      assert_select "input#notification_target_type[name=?]", "notification[target_type]"
    end
  end
end
