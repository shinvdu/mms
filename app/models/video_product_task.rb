class VideoProductTask < LocalTask
  belongs_to :target, :class_name => 'VideoProduct'

  def process
    logger.info 'Start process VideoProductTask'
    video_product = self.target
    transcoding = video_product.transcoding
    video_product_group = video_product.video_product_group
    logger.debug "[video product group id: #{video_product_group.id}"
    user_video = video_product_group.user_video
    logger.debug "[user video id: #{user_video.id}, transcoding id: #{transcoding.id}]"
    dependent_video = VideoDetail.find_by_user_video_id_and_transcoding_id(user_video.id, transcoding.id)
    if dependent_video.nil?
      logger.info 'Dependent video not found, transcode to get it.'
      user_video.create_transcoding_video_job(transcoding)
      return
    end
    logger.debug "[dependent video id: #{dependent_video.id}]"
    if dependent_video.PROCESSING?
      logger.info 'Wait for next loop because dependent video is in processing'
      video_product.status = VideoProduct::STATUS::WAIT_FOR_DEPENDENCY
      video_product.save!
      return
    end
    if dependent_video.ONLY_REMOTE?
      logger.info 'Dependent video is only in remote server(OSS), download before cut'
      video_product.status = VideoProduct::STATUS::DOWNLOADING
      video_product.save!
      file_path = dependent_video.get_full_path
      cache_path = dependent_video.full_cache_path!
      if !File.exist? cache_path
        raise Exception.new "Cached file not found in: #{cache_path}"
      end
      logger.debug "cp #{cache_path} #{file_path}"
      FileUtils.cp cache_path, file_path
      # must cp before save, save will remove cached file
      dependent_video.status = VideoDetail::STATUS::BOTH
      dependent_video.save!
    end

    logger.info 'Start to make video product fragment'
    self.status = VideoProductTask::STATUS::PROCESSING
    video_product.status = VideoProduct::STATUS::PROCESSING
    video_product.save!
    video_product_group.video_fragments.each do |frag, idx|
      product_fragment = VideoProductFragment.create(:video_product => video_product, :video_fragment => frag, :order => idx)
      product_fragment.produce(dependent_video)
      product_fragment.save!
    end

    video_product.status = VideoProduct::STATUS::FINISHED
    video_product.save!
    self.status = VideoProductTask::STATUS::FINISHED
    self.save!
  end
end

#------------------------------------------------------------------------------
# VideoProductTask
#
# Name                SQL Type             Null    Default Primary
# ------------------- -------------------- ------- ------- -------
# id                  int(11)              false           true   
# status              int(11)              true            false  
# target_id           int(11)              true            false  
# finish_time         datetime             true            false  
# message             varchar(255)         true            false  
# prediction_time     datetime             true            false  
# percent             int(11)              true            false  
# local_task_group_id int(11)              true            false  
# dependency_id       int(11)              true            false  
# created_at          datetime             false           false  
# updated_at          datetime             false           false  
# type                varchar(255)         true            false  
#
#------------------------------------------------------------------------------
