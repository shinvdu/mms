class Advertise::Resource < ActiveRecord::Base
  belongs_to :user
  belongs_to :video_detail, :class_name => 'VideoDetail', :foreign_key => :advertise_resource_id
  mount_uploader :uri, AdResourceUploader

  validates :name, presence: true
  validates :file_type, presence: true
  validates :ad_type, presence: true

  attr_accessor :ext_name, :file_name, :resource

  include MTSUtils::All

  def set_ad_video(video)
    self.file_name = video.original_filename
    self.ext_name = File.extname(self.file_name)

    video_detail = VideoDetail.new.set_ad_video(self, video)
    video_detail.save!
    self.video_detail = video_detail
    # self.status = STATUS::PREUPLOADED
    self.delay.fetch_video_info_and_upload
    self
  end

  def fetch_video_info_and_upload
    video_detail = self.video_detail
    video_detail.fetch_video_info
    video_detail.load_local_file!
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