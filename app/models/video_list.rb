class VideoList < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User'
  has_many :video_list_links
  has_many :user_videos, :through => :video_list_links
  has_many :video_product_group_list_links
  has_many :video_product_groups, :through => :video_product_group_list_links
  has_many :video_list_privileges, :dependent => :delete_all
  has_many :privilege_members, :through => :video_list_privileges, :source => 'user'
  scope :get_by_user, -> (user) { where(:owner => user) }

  def set_privileges(privileges)
    transaction do
      member_ids = privileges.values.reduce { |s, ids| s | ids } || []
      exist_member_ids = []
      self.video_list_privileges.each do |privilege|
        user_id = privilege.user_id
        if member_ids.exclude? user_id
          privilege.destroy
        else
          exist_member_ids.append user_id
          privilege.update_privileges!(privileges)
        end
      end
      (member_ids - exist_member_ids).each do |member_id|
        privilege = VideoListPrivilege.new(:video_list => self, :user_id => member_id)
        privilege.update_privileges!(privileges)
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
