class VideoCutPoint < ActiveRecord::Base
  belongs_to :user_video

  def self.create_by_user(cut_points)
    video_cut_points = VideoCutPoint.create(cut_points)
    video_cut_points.each do |cp|
      cp.user_created = true
      cp.save!
    end
    video_cut_points
  end
end

#------------------------------------------------------------------------------
# VideoCutPoint
#
# Name          SQL Type             Null    Default Primary
# ------------- -------------------- ------- ------- -------
# id            int(11)              false           true   
# start_time    float                true            false  
# stop_time     float                true            false  
# user_created  tinyint(1)           true            false  
# user_video_id int(11)              true            false  
# created_at    datetime             false           false  
# updated_at    datetime             false           false  
# name          varchar(255)         true            false  
#
#------------------------------------------------------------------------------
