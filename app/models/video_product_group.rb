class VideoProductGroup < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User'
  belongs_to :creator, :class_name => 'User'
  belongs_to :user_video
  belongs_to :temp_video, :class_name => 'VideoDetail'
  belongs_to :player
  has_many :video_products, :dependent => :delete_all
  has_many :video_fragments, -> { order('video_fragments.order') }, :dependent => :delete_all
  has_many :video_cut_points, -> { order 'video_fragments.order' }, :through => :video_fragments
  has_many :snapshots
  has_one :video_product_group_list_link, :dependent => :delete
  has_one :video_list, :through => :video_product_group_list_link
  belongs_to :transcoding_strategy
  belongs_to :checker, :class_name => 'User'
  scope :need_check, -> { where(['check_status in (?, ?) and status = ?', CHECK_STATUS::UNCHECKED, CHECK_STATUS::PENDING, STATUS::FINISHED]) }
  before_save :set_uuid
  before_save do
    self.show_id = VideoProductGroup.generate_id if show_id.nil?
  end
  include Privilege

  module STATUS
    CREATED = 5
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
    cut_points.each_with_index do |cp, idx|
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

  def total_size
    return unless self.FINISHED?
    sum = 0
    self.video_products.each { |product| sum += product.video_detail.size }
    sum
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

  def status_str
    case self.get_status
      when STATUS::CREATED
        if self.user_video.GOT_LOW_RATE?
          '等待剪辑'
        else
          '预处理中'
        end
      when (STATUS::SUBMITTED..STATUS::UPLOADING)
        '处理中'
      when STATUS::FINISHED
        '完成'
      when STATUS::FAILED
        '失败'
      else
        '未知状态'
    end
  end

  def duration_str
    return '未知' unless self.FINISHED?
    return self.temp_video.duration.to_time if self.temp_video && self.temp_video.duration
    return self.user_video.duration.to_time if self.user_video
  end

  def FINISHED?
    self.get_status == STATUS::FINISHED
  end

  def ACCEPTED?
    self.check_status == CHECK_STATUS::ACCEPTED
  end

  def CREATED?
    self.get_status == STATUS::CREATED
  end

  require 'uuidtools'

  def set_uuid
    self.uuid ||= UUIDTools::UUID.random_create.to_s
  end

  #####################################################
  # video list
  #####################################################

  def set_video_list_by_user_video(user_video)
    if user_video.present?
      video_list = user_video.video_list
      self.create_video_product_group_list_link(:video_list => video_list) if video_list.present?
    end
  end

  #####################################################
  # asynchronous method
  #####################################################

  def logger
    Delayed::Worker.logger
  end

  def check_dependent
    self.video_cut_points.each do |cp|
      dependent_video = cp.user_video.mkv_video
      if dependent_video.nil? || dependent_video.NONE?
        logger.warn "Cannot find mkv video for user video. [id: #{cp.user_video.id}]"
        self.status = STATUS::WAIT_FOR_DEPENDENCY
        self.save!
        self.delay(run_at: 1.seconds.from_now).create_products_from_mkv
        return false
      end
      logger.debug "[dependent video id: #{dependent_video.id}]"
      if dependent_video.PROCESSING?
        logger.info 'Wait for next loop because dependent video is in processing'
        self.status = STATUS::WAIT_FOR_DEPENDENCY
        self.save!
        self.delay(run_at: 1.seconds.from_now).create_products_from_mkv
        return false
      end
    end
    self.video_cut_points.each do |cp|
      dependent_video = cp.user_video.mkv_video
      unless dependent_video.LOCAL?
        logger.info 'Dependent video is only in remote server(OSS), download before cut'
        self.status = STATUS::DOWNLOADING
        self.save!
        dependent_video.download!
      end
      dependent_video.load_local_file_if_necessary!
    end
    true
  end

  def create_products_from_mkv
    logger.info 'Start process video product group'
    return unless check_dependent

    create_products_by_transcoding_strategy
  end

  def create_package_product
    logger.info 'Start process video product group'
    create_products_for_directly_publish(self.user_video.original_video)
  end

  def create_products_from_origin
    self.status = STATUS::PROCESSING
    self.save!
    self.transcoding_strategy.transcodings.each do |transcoding|
      product = VideoProduct.create(:video_product_group => self, :transcoding => transcoding)
      product.transcode_video(self.user_video.original_video, transcoding, self.creator.enabled_water_mark.water_mark_template)
    end
    self.user_video.original_video.create_snapshot(self)
  end

  def create_products_by_transcoding_strategy
    logger.info 'Start to make video product fragment'
    self.status = STATUS::PROCESSING
    self.save!
    # self.temp_video = dependent_video.create_mkv_video_by_fragments(self.video_fragments)
    self.temp_video = VideoDetail.create_mkv_video_by_fragments(self.video_fragments)
    self.temp_video.load_local_file! unless self.temp_video.REMOTE?
    self.temp_video.create_snapshot(self)
    self.temp_video.remove_local_file!

    self.transcoding_strategy.transcodings.each do |transcoding|
      product = VideoProduct.create(:video_product_group => self, :transcoding => transcoding)
      product.transcode_video(self.temp_video, transcoding, self.creator.enabled_water_mark.water_mark_template)
    end
    self.save!
  end

  def create_products_for_directly_publish(dependent_video)
    logger.info 'Start to make packaged video product'
    self.status = STATUS::PROCESSING
    self.save!
    self.temp_video = VideoDetail.create.copy_video_info_from! dependent_video
    product = VideoProduct.create(:video_product_group => self)
    dependent_video.download!
    product.publish_mp4!(dependent_video)
    dependent_video.create_snapshot(self)
    self.status = STATUS::FINISHED
    self.save!
  end

  def check_all_finished
    not_all_finished = self.video_products.any? { |products| !products.FINISHED? }
    unless not_all_finished
      self.status = VideoProductGroup::STATUS::FINISHED
      self.temp_video.remove_local_file!
      self.save!
    end
  end

  ######################################################
  # check status
  ######################################################

  def check(checker_admin, result)
    if [CHECK_STATUS::ACCEPTED, CHECK_STATUS::REJECT, CHECK_STATUS::PENDING].include? result
      self.check_status = result
      self.checker = checker_admin
      self.save!
    end
  end

  def check_status_str
    case check_status
      when CHECK_STATUS::UNCHECKED
        '未审核'
      when CHECK_STATUS::PENDING
        '稍后审核'
      when CHECK_STATUS::ACCEPTED
        '审核通过'
      when CHECK_STATUS::REJECT
        '审核未通过'
    end
  end

  def NEED_CHECK?
    [CHECK_STATUS::UNCHECKED, CHECK_STATUS::PENDING].include? self.check_status
  end

  def self.generate_id
    t = DateTime
    id = t.now.strftime("%Y%m%d%H%M%S%L")
    # Get current date to the milliseconds
    id = [id, rand(10000000)].join('')
    id = id.to_i.to_s(36)
  end

  ######################################################
  # remove
  ######################################################
  def destroy
    self.snapshots.each { |snapshot| snapshot.destroy if snapshot.video_detail.nil? }
    super
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
# status                  int(11)              true    10      false  
# created_at              datetime             false           false  
# updated_at              datetime             false           false  
# transcoding_strategy_id int(11)              true            false  
# name                    varchar(255)         true            false  
# temp_video_id           int(11)              true            false  
# check_status            int(11)              true    10      false  
# checker_id              int(11)              true            false  
# uuid                    varchar(255)         true            false  
# player_id               int(11)              true            false  
# creator_id               int(11)              true            false  
#
#------------------------------------------------------------------------------
