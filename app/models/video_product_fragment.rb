class VideoProductFragment < ActiveRecord::Base
  belongs_to :video_product
  belongs_to :video_fragment
  belongs_to :video_detail
  before_save :default_values

  module STATUS
    NOT_STARTED = 10
    SUBMITTED = 20
    PROCESSING = 30
    CUT_FINISHED = 40
    UPLOADED = 50
  end

  # def initialize(product, fragment, order)
  #   self.video_product = product
  #   self.video_fragment = fragment
  #   self.order = order
  #   self.status = STATUS::NOT_STARTED
  # end

  def start_cut_task(group)
    dependent_video = VideoDetail.find_by_user_video_and_transcoding(self.video_product.video_product_group.user_video,
                                                                     self.video_product.transcoding)
    task = VideoFragmentTask.new(:local_task_group => group, :target => self, :dependency => dependent_video)
    task.save!
  end

  def default_values
    self.status ||= STATUS::NOT_STARTED
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
# status            int(11)              true            false  
# created_at        datetime             false           false  
# updated_at        datetime             false           false  
#
#------------------------------------------------------------------------------
