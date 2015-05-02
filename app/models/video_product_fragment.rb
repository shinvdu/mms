class VideoProductFragment < ActiveRecord::Base
  belongs_to :video_product
  belongs_to :video_fragment
  belongs_to :video_detail

  module STATUS
    NOT_STARTED = 10
    SUBMITTED = 20
    PROCESSING = 30
    CUT_FINISHED = 40
    UPLOADED = 50
  end

  def produce(dependent_video)
    cut_point = video_fragment.video_cut_point
    self.video_detail = dependent_video.create_sub_video(cut_point.start_time, cut_point.stop_time, self.id)
    self.video_detail.fetch_video_info
    self.video_detail.save!
    logger.debug "upload successfully for fragment. id: #{self.id}"

    # start_time = get_time(video_fragment.video_cut_point.start_time)
    # stop_time = get_time(video_fragment.video_cut_point.stop_time)
    # input_path = Rails.root.join(Settings.file_server.dir, dependent_video.uri).to_s
    # output_path = input_path.split('.').insert(-2, self.id).join('.')
    # # video slice
    # logger.debug `ffmpeg -i #{input_path} -ss #{start_time} -to #{stop_time} -vcodec copy -acodec copy -y #{output_path}`
    # `ffmpeg -i #{input_path} -ss #{start_time} -to #{stop_time} -vcodec copy -acodec copy -y #{output_path}`
    # fragment_video = dependent_video.dup
    # fragment_video.uri = dependent_video.uri.split('.').insert(-2, self.id).join('.')
    # File.open(output_path) do |f|
    #   fragment_video.video = f
    #   fragment_video.save!
    # end
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
