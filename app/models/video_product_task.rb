class VideoProductTask < LocalTask
  belongs_to :target, :class_name => 'VideoProduct'

  def process
    logger.info 'Start process VideoProductTask'
    video_product = self.target
    transcoding = video_product.transcoding
    video_product_group = video_product.video_product_group
    logger.debug "video product group id: #{video_product_group.id}"
    user_video = video_product_group.user_video
    dependent_video = user_video.mkv_video
    if dependent_video.nil?
      logger.error "Cannot find mkv video for user video. id: #{user_video.id}"
      self.status = STATUS::FAILED
      self.save!
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
      dependent_video.download!
    end

    logger.info 'Start to make video product fragment'
    self.status = VideoProductTask::STATUS::PROCESSING
    video_product.status = VideoProduct::STATUS::PROCESSING
    video_product.save!
    video_product.produce!(dependent_video, video_product_group.video_fragments)

    fragments = []
    video_product_group.video_fragments.each_with_index do |frag, idx|
      product_fragment = VideoProductFragment.create(:video_product => video_product, :video_fragment => frag, :order => idx)
      product_fragment.produce(dependent_video)
      fragments.append product_fragment
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
