module LocalVideoWorker
  module Scheduled
    require 'fileutils'

    def process_video_product_task
      VideoProductTask.not_finished.each do |task|
        logger.info 'Start process VideoProductTask'
        video_product = task.target
        transcoding = video_product.transcoding
        video_product_group = video_product.video_product_group
        user_video = video_product_group.user_video
        dependent_video = VideoDetail.find_by_user_video_id_and_transcoding_id(user_video.id, transcoding.id)
        if dependent_video.nil?
          logger.info 'Dependent video not found, transcode to get it'
          user_video.create_transcoding_video_job(transcoding)
          return
        end
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
          dependent_video.video.cache_stored_file!
          file_path = dependent_video.get_full_path
          cache_path = full_cache_path(dependent_video.video)
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
        task.status = VideoProductTask::STATUS::PROCESSING
        video_product.status = VideoProduct::STATUS::PROCESSING
        video_product.save!
        video_product_group.video_fragments.each do |frag, idx|
          product_fragment = VideoProductFragment.create(:video_product => video_product, :video_fragment => frag, :order => idx)
          product_fragment.produce(dependent_video)
          product_fragment.save!
        end

        video_product.status = VideoProduct::STATUS::FINISHED
        video_product.save!
        task.status = VideoProductTask::STATUS::FINISHED
        task.save!
      end
    end

    def full_cache_path(cache)
      Rails.root.join('public', cache.cache_dir, cache.cache_name)
    end
  end
end