module VideoWorker
  module UserVideoWorker
    include MTSUtils::All

    def fetch_video_info_and_upload
      video_detail = self.original_video
      local_path = Rails.root.join(Settings.file_server.dir, video_detail.uri)
      File.open(local_path) do |file|
        video_detail.video = file
        video_detail.save!
        self.status = UserVideo::STATUS_UPLOADED
      end
      create_fetch_video_info_job(video_detail)
      create_minimal_video_job(video_detail)
      self.status = UserVideo::STATUS_PRETRANSCODING
    end

    # handle_asynchronously :fetch_video_info_and_upload

    def create_fetch_video_info_job(video_detail)
      request_id, meta_info_job = submit_meta_info_job(Settings.aliyun.oss.bucket, video_detail.uri)
      MetaInfoJob.new(meta_info_job.job_id, self).save!
    end

    def create_minimal_video_job(video_detail)
      output_object_uri = video_detail.uri.split('.').insert(-2, Settings.aliyun.oss.mini_suffix).join('.')
      request_id, job_result = submit_job(Settings.aliyun.oss.bucket,
                                          video_detail.uri,
                                          output_object_uri,
                                          Settings.aliyun.mts.mini_template_id,
                                          Settings.aliyun.mts.pipeline_id)
      if job_result.success
        mini_video_detail = video_detail.dup
        mini_video_detail.user_video = video_detail.user_video
        mini_video_detail.uri = output_object_uri
        mini_video_detail.save!
        MiniTranscodeJob.new(job_result.job.job_id, self).save!
      end
    end
  end


  def auto_query_loop

  end

  handle_asynchronously :auto_query_loop
end