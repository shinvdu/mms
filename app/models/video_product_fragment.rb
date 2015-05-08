class VideoProductFragment < ActiveRecord::Base
  belongs_to :video_product
  belongs_to :video_fragment
  belongs_to :video_detail

  module STATUS
    NOT_STARTED = 10
    SUBMITTED = 20
    PROCESSING = 30
    CUT_FINISHED = 40
    UPLOADED = 50
  end

  # fragment has no necessary to save
  # it will be used to merge directly
  def save
  end
  def save!
  end

  def produce(dependent_video)
    cut_point = video_fragment.video_cut_point
    self.video_detail = dependent_video.create_sub_video(cut_point.start_time, cut_point.stop_time, self.id)
    self.video_detail.fetch_video_info
    self.video_detail.save!
    logger.debug "upload successfully for fragment. id: #{self.id}"
  end
end

#------------------------------------------------------------------------------
# VideoProductFragment
#
# Name              SQL Type             Null    Default Primary
# ----------------- -------------------- ------- ------- -------
# id                int(11)              false           true   
# video_product_id  int(11)              true            false  
# video_fragment_id int(11)              true            false  
# video_detail_id   int(11)              true            false  
# order             int(11)              true            false  
# status            int(11)              true    10      false  
# created_at        datetime             false           false  
# updated_at        datetime             false           false  
#
#------------------------------------------------------------------------------
