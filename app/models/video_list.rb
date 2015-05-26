class VideoList < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User'
  has_many :video_list_links
  has_many :user_videos, :through => :video_list_links
  has_many :video_product_group_list_links
  has_many :video_product_groups, :through => :video_product_group_list_links
  has_many :video_list_privileges, :dependent => :delete_all
  has_many :privilege_members, :through => :video_list_privileges, :source => 'user'
  scope :get_by_user, -> (user) { where(:owner => user) }

  def set_privilege_members(member_ids)
    transaction do
      exist_member_ids = []
      self.video_list_privileges.each do |privilege|
        if member_ids.exclude? privilege.user_id
          privilege.destroy
        else
          exist_member_ids.append privilege.user_id
        end
      end
      member_ids.each do |member_id|
        VideoListPrivilege.create(:video_list => self, :user_id => member_id) if exist_member_ids.exclude? member_id
      end
    end
  end
end

#------------------------------------------------------------------------------
# VideoList
#
# Name       SQL Type             Null    Default Primary
# ---------- -------------------- ------- ------- -------
# id         int(11)              false           true   
# name       varchar(255)         true            false  
# owner_id   int(11)              true            false  
# created_at datetime             false           false  
# updated_at datetime             false           false  
#
#------------------------------------------------------------------------------
