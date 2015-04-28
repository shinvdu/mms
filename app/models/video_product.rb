class VideoProduct < ActiveRecord::Base
  belongs_to :video_product_group
  has_many :video_product_fragments, -> { order('order') }
  belongs_to :video_detail
  belongs_to :transcoding
  before_save :default_values

  module STATUS
    NOT_STARTED = 10
    WAIT_FOR_DEPENDENCY = 20
    DOWNLOADING = 30
    PROCESSING = 40
    UPLOADING = 50
    FINISHED = 60
  end

  def make_video_product_task
    VideoProductGroupTaskGroup.new(:target => self.video_product_group)
    VideoProductTask.new(:target => self)
  end

  handle_asynchronously :make_video_product_task

  def default_values
    self.status ||= STATUS::NOT_STARTED
  end
end

#------------------------------------------------------------------------------
# VideoProduct
#
# Name                   SQL Type             Null    Default Primary
# ---------------------- -------------------- ------- ------- -------
# id                     int(11)              false           true   
# video_product_group_id int(11)              true            false  
# video_detail_id        int(11)              true            false  
# transcoding_id         int(11)              true            false  
# progress               int(11)              true            false  
# status                 int(11)              true            false  
# created_at             datetime             false           false  
# updated_at             datetime             false           false  
#
#------------------------------------------------------------------------------
