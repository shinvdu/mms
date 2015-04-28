module LocalVideoWorker
  module Scheduled
    require 'fileutils'

    def process_video_product_task
      VideoProductTask.not_finished.each do |task|
        video_product = task.target
        transcoding = video_product.transcoding
        video_product_group = video_product.video_product_group
        user_video = video_product_group.user_video
        dependent_video = video_detail.find_by_user_video_and_transcoding(user_video, transcoding)
        if dependent_video.nil?
          user_video.create_transcoding_video_job(transcoding)
          return
        end
        return if dependent_video.PROCESSING?
        if dependent_video.ONLY_REMOTE?
          #TODO download
          dependent_video.video.cache_stored_file!
          file_path = Rails.root.join(Settings.file_server.dir, dependent_video.uri)
          FileUtils.mv dependent_video.video.full_cache_path file_path

          dependent_video.status = VideoDetail::STATUS::BOTH
        end

        task.status = VideoProductTask::STATUS::PROCESSING
        video_product_group.video_fragments.each do |frag, idx|
          product_fragment = VideoProductFragment.new(:video_product => self, :video_fragment => frag, :order => idx)
          product_fragment.produce(dependent_video)
        end

        task.status = VideoProductTask::STATUS::FINISHED
      end
    end
  end
end