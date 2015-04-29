class VideoProductGroup < ActiveRecord::Base
  belongs_to :user_video
  has_many :video_products
  has_many :video_fragments, -> { order('video_fragments.order') }
  has_many :video_cut_points, -> { order 'video_fragments.order' }, :through => :video_fragments
  belongs_to :transcoding_strategy
  before_save :default_values

  module STATUS
    WAITING_FOR_PROCESSING = 10
  end

  def create_fragments(cut_points)
    cut_points.each do |cp, idx|
      VideoFragment.create(:video_product_group => self,
                           :video_cut_point => cp,
                           :order => idx)
    end
  end

  def create_products(transcodings)
    task_group = VideoProductGroupTaskGroup.create(:target => self)
    # make video product for each transcoding in self.transcoding_strategy
    self.transcoding_strategy.transcodings.each do |transcoding|
      product = VideoProduct.create(:video_product_group => self, :transcoding => transcoding)
      product.make_video_product_task(task_group)
    end
  end

  def default_values
    self.status ||= STATUS::WAITING_FOR_PROCESSING
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
# name                    varchar(255)         true            false  
#
#------------------------------------------------------------------------------
