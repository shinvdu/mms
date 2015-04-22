class VideoProductGroup < ActiveRecord::Base
  belongs_to :user_video
  has_many :video_fragments
  has_many :video_cut_points, -> { order 'video_fragments.order' }, :through => :video_fragments

  @@WAITING_FOR_PROCESSING = 1

  def new(attributes, &block)
    super
    self.status = @@WAITING_FOR_PROCESSING
  end
end

#------------------------------------------------------------------------------
# VideoProductGroup
#
# Name            SQL Type             Null    Default Primary
# --------------- -------------------- ------- ------- -------
# id              int(11)              false           true   
# owner_id        int(11)              true            false  
# user_video_id   int(11)              true            false  
# video_config_id int(11)              true            false  
# published       tinyint(1)           true            false  
# publish_start   time                 true            false  
# publish_stop    time                 true            false  
# created_at      datetime             false           false  
# updated_at      datetime             false           false  
# status          int(11)              true            false  
#
#------------------------------------------------------------------------------
