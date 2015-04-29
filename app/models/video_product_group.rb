class VideoProductGroup < ActiveRecord::Base
  belongs_to :user_video
  has_many :video_products
  has_many :video_fragments, -> { order('video_fragments.order') }
  has_many :video_cut_points, -> { order 'video_fragments.order' }, :through => :video_fragments
  belongs_to :transcoding_strategy
  before_save :default_values

  module STATUS
    SUBMITTED = 10
    PROCESSING = 20
    FINISHED = 30
  end

  def create_fragments(cut_points)
    cut_points.each do |cp, idx|
      VideoFragment.create(:video_product_group => self,
                           :video_cut_point => cp,
                           :order => idx)
    end
  end

  def create_products
    task_group = VideoProductGroupTaskGroup.create(:target => self)
    # make video product for each transcoding in self.transcoding_strategy
    self.transcoding_strategy.transcodings.each do |transcoding|
      product = VideoProduct.create(:video_product_group => self, :transcoding => transcoding)
      product.make_video_product_task(task_group)
    end
  end

  def get_m3u8_file_path
    file_path = Rails.root.join(Settings.m3u8_dir, [self.id, 'm3u8'].join('.'))
    dir = File.dirname file_path
    FileUtils.mkdir_p dir if !File.exist? dir
    if !File.exist? file_path
      File.open file_path, 'w' do |file|
        file.puts '#EXTM3U'
        self.video_products.each do |product|
          product.video_product_fragments.each do |fragment|
            file.puts
            file.puts "#EXTINF:#{fragment.video_detail.duration}, vdo "
            file.puts fragment.video_detail.get_full_url
          end
        end
      end
    end
    file_path
  end

  def get_status
    stat = self.status
    if stat != STATUS::FINISHED
      stat = STATUS::FINISHED if self.video_products.present?
      self.video_products.each do |product|
        stat = STATUS::PROCESSING if !product.FINISHED?
      end
      self.status = stat
      self.save! if self.changed?
    end
    stat
  end

  def default_values
    @status ||= STATUS::SUBMITTED
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
