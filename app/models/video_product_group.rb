class VideoProductGroup < ActiveRecord::Base
  belongs_to :user_video
  has_many :video_products
  has_many :video_fragments, -> { order('order') }
  has_many :video_cut_points, -> { order 'video_fragments.order' }, :through => :video_fragments
  belongs_to :transcoding_strategy

  module STATUS
    WAITING_FOR_PROCESSING = 10
  end

  def initialize(user_video, transcoding_strategy)
    super()
    self.status = STATUS::WAITING_FOR_PROCESSING
    self.user_video = user_video
    self.transcoding_strategy = transcoding_strategy
  end
end

#------------------------------------------------------------------------------
# VideoProductGroup
#
# Name                    SQL Type             Null    Default Primary
# ----------------------- -------------------- ------- ------- -------
# id                      int(11)              false           true   
# owner_id                int(11)              true            false  
# user_video_id           int(11)              true            false  
# video_config_id         int(11)              true            false  
# published               tinyint(1)           true            false  
# publish_start           time                 true            false  
# publish_stop            time                 true            false  
# status                  int(11)              true            false  
# created_at              datetime             false           false  
# updated_at              datetime             false           false  
# transcoding_strategy_id int(11)              true            false  
#
#------------------------------------------------------------------------------
