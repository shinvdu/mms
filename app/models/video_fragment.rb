class VideoFragment < ActiveRecord::Base
  belongs_to :video_product_group
  belongs_to :video_cut_point

  def slice_mkv_video(output_path)
    input_path = self.video_cut_point.user_video.mkv_video.get_full_path
    raise 'input video not found' unless File.exist? input_path
    cp = video_cut_point
    time_str = "#{cp.start_time.to_time}-#{cp.stop_time.to_time}"
    logger.debug "[command] mkvmerge -o #{output_path} --split parts:#{time_str} #{input_path}"
    `mkvmerge -o #{output_path} --split parts:#{time_str} #{input_path}`
  end
end

#------------------------------------------------------------------------------
# VideoFragment
#
# Name                   SQL Type             Null    Default Primary
# ---------------------- -------------------- ------- ------- -------
# id                     int(11)              false           true   
# video_product_group_id int(11)              true            false  
# video_cut_point_id     int(11)              true            false  
# order                  int(11)              true            false  
# created_at             datetime             false           false  
# updated_at             datetime             false           false  
#
#------------------------------------------------------------------------------
