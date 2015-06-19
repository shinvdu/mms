class VideoListPrivilege < ActiveRecord::Base
  belongs_to :user
  belongs_to :video_list

  def update_privileges!(privileges)
    Settings.video_privilege.keys.each do |pri|
      self["can_#{pri}"] = privileges[pri].present? && privileges[pri].include?(user_id)
    end
    self.save!
  end
end

#------------------------------------------------------------------------------
# VideoListPrivilege
#
# Name          SQL Type             Null    Default Primary
# ------------- -------------------- ------- ------- -------
# id            int(11)              false           true   
# user_id       int(11)              true            false  
# video_list_id int(11)              true            false  
# created_at    datetime             false           false  
# updated_at    datetime             false           false  
# can_edit      tinyint(1)           true    0       false  
# can_clip      tinyint(1)           true    0       false  
# can_publish   tinyint(1)           true    0       false  
# can_upload    tinyint(1)           true    0       false  
# can_delete    tinyint(1)           true    0       false  
#
#------------------------------------------------------------------------------
