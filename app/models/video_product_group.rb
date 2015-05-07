class VideoProductGroup < ActiveRecord::Base
  belongs_to :user_video
  belongs_to :mkv_video, :class_name => 'VideoDetail'
  has_many :video_products
  has_many :video_fragments, -> { order('video_fragments.order') }
  has_many :video_cut_points, -> { order 'video_fragments.order' }, :through => :video_fragments
  belongs_to :transcoding_strategy
  belongs_to :checker, :class_name => 'User'

  module STATUS
    SUBMITTED = 10
    WAIT_FOR_DEPENDENCY = 20
    DOWNLOADING = 30
    PROCESSING = 40
    UPLOADING = 50
    FINISHED = 60
    FAILED = 99
  end

  module CHECK_STATUS
    UNCHECKED = 10
    PENDING = 20
    ACCEPTED = 30
    REJECT = 99
  end

  def create_fragments(cut_points)
    cut_points.each do |cp, idx|
      VideoFragment.create(:video_product_group => self,
                           :video_cut_point => cp,
                           :order => idx)
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

  #####################################################
  # asynchronous method
  #####################################################

  def logger
    Delayed::Worker.logger
  end

  def create_products
    logger.info 'Start process video product group'
    video_product_group = self
    logger.debug "video product group id: #{video_product_group.id}"
    user_video = self.user_video
    dependent_video = user_video.mkv_video

    if dependent_video.nil?
      logger.error "Cannot find mkv video for user video. id: #{user_video.id}"
      self.status = STATUS::FAILED
      self.save!
      self.delay.create_products
      return
    end

    logger.debug "[dependent video id: #{dependent_video.id}]"
    if dependent_video.PROCESSING?
      logger.info 'Wait for next loop because dependent video is in processing'
      self.status = STATUS::WAIT_FOR_DEPENDENCY
      self.save!
      self.delay.create_products
      return
    end

    if dependent_video.ONLY_REMOTE?
      logger.info 'Dependent video is only in remote server(OSS), download before cut'
      self.status = STATUS::DOWNLOADING
      self.save!
      dependent_video.download!
    end

    logger.info 'Start to make video product fragment'
    self.status = STATUS::PROCESSING
    self.save!
    self.mkv_video = dependent_video.create_mkv_video_by_fragments(self.video_fragments)
    self.mkv_video.fetch_video_info
    self.mkv_video.load_local_file! unless self.mkv_video.REMOTE?
    self.mkv_video.create_snapshot
    self.mkv_video.remove_local_file!

    self.transcoding_strategy.transcodings.each do |transcoding|
      product = VideoProduct.create(:video_product_group => self, :transcoding => transcoding)
      product.transcode_video(self.mkv_video, transcoding)
    end

    self.save!
  end

  def check_all_finished
    not_all_finished = self.video_products.any? { |products| !products.FINISHED? }
    unless not_all_finished
      self.status = VideoProductGroup::STATUS::FINISHED
      self.mkv_video.remove_local_file!
      self.save!
    end
  end

  ######################################################
  # check status
  ######################################################

  def check(checker_admin, result)
    if [CHECK_STATUS::ACCEPTED, CHECK_STATUS::REJECT, CHECK_STATUS::PENDING].include?(result)
      self.check_status = result
      self.checker = checker_admin
    end
  end

  def NEED_CHECK?
    [CHECK_STATUS::UNCHECKED, CHECK_STATUS::PENDING].include? self.check_status
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
