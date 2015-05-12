class Advertise::Resource < ActiveRecord::Base
  belongs_to :user
  belongs_to :video_detail, :foreign_key => :video_detail_id
  belongs_to :transcoded_video, :class_name => 'VideoDetail'
  mount_uploader :uri, AdResourceUploader

  validates :name, presence: true
  validates :file_type, presence: true
  validates :ad_type, presence: true

  attr_accessor :ext_name, :file_name, :resource

  include MTSUtils::All

  module STATUS
    PREUPLOADED = 10
    UPLOADED = 20
    TRANSCODED = 30
    TRANSCODE_FAILED = 40
  end

  module FORMAT_STATUS
    NORMAL = 0
    BAD_FORMAT_FOR_PACKAGE = 1
    BAD_FORMAT_FOR_MTS = 2
  end

  def set_ad_video(video)
    self.file_name = video.original_filename
    self.ext_name = File.extname(self.file_name)

    self.video_detail = VideoDetail.new.set_ad_video(self, video)
    self.video_detail.save!
    self.status = STATUS::PREUPLOADED
    self.save!
    self.delay.fetch_video_info_and_upload
    self
  end

  ######################################################
  # asynchronous method
  ######################################################

  def fetch_video_info_and_upload
    self.video_detail.fetch_video_info
    unless self.video_detail.mts_accept?
      logger.info "video format is bad, stop to call mts to transcode. [video detail id: #{self.video_detail.id}]"
      self.format_status = UserVideo::FORMAT_STATUS::BAD_FORMAT_FOR_MTS
      self.save!
      return
    end
    self.video_detail.load_local_file!
    self.status = STATUS::UPLOADED
    job = self.video_detail.create_transcoding_video_job(Transcoding.find_ad_template, true)
    self.transcoded_video = job.target
    job.post_process_command = "Advertise::Resource.find(#{self.id}).video_transcode_finished"
    job.save!
    self.save!
  end

  def video_transcode_finished
    self.status = STATUS::TRANSCODED
    self.save!
  end
end

# +-----------------+--------------+------+-----+---------+----------------+
# | Field           | Type         | Null | Key | Default | Extra          |
# +-----------------+--------------+------+-----+---------+----------------+
# | id              | int(11)      | NO   | PRI | NULL    | auto_increment |
# | name            | varchar(255) | YES  |     | NULL    |                |
# | user_id         | int(11)      | YES  |     | NULL    |                |
# | file_type       | varchar(255) | YES  |     | NULL    |                |
# | ad_type         | varchar(255) | YES  |     | NULL    |                |
# | filesize        | int(11)      | YES  |     | NULL    |                |
# | uri             | varchar(255) | YES  |     | NULL    |                |
# | ad_word         | text         | YES  |     | NULL    |                |
# | data            | text         | YES  |     | NULL    |                |
# | created_at      | datetime     | NO   |     | NULL    |                |
# | updated_at      | datetime     | NO   |     | NULL    |                |
# | video_detail_id | int(11)      | YES  |     | NULL    |                |
# +-----------------+--------------+------+-----+---------+----------------+