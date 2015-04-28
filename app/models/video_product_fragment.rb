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

  def produce(dependent_video)
    start_time = 0
    stop_time = 1
    input_path = File.join(Settings.file_server.dir, dependent_video.uri)
    output_path = input_path.split('/').insert(-2, 'fragment').join('/').split('.').insert(-2, self.id).join('.')
    # video slice
    `ffmpeg -ss 00:00:02 -i #{input_path} -t 00:00:04 -vcodec copy -acodec copy -y #{output_path}`
    fragment_video = dependent_video.dup
    fragment_video.uri = dependent_video.uri.split('.').insert(-2, self.id).join('.')
    fragment_video.video = nil#TODO
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
