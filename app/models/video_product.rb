class VideoProduct < ActiveRecord::Base
  belongs_to :video_product_group
  has_many :video_product_fragments, -> { order('order') }
  belongs_to :video_detail
  belongs_to :transcoding

  module STATUS
    NOT_STARTED = 10
    DOWNLOADING = 20
    PROCESSING = 30
    UPLOADING = 40
    FINISHED = 50
  end

  def initialize(group, transcoding)
    self.video_product_group = group
    self.transcoding = transcoding
  end

  # include LocalVideoWorker::VideoProductWorker

  def make_fragment
    group = self.video_product_group
    task_group = VideoProductTaskGroup.new(:target => self)
    group.video_fragments.each do |frag, idx|
      product_fragment = VideoProductFragment.new(:video_product => self, :video_fragment => frag, :order => idx)
      product_fragment.start_cut_task(task_group)
    end
    self.status = STATUS::NOT_STARTED
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
