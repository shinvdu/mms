module MTSWorker
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

    handle_asynchronously :fetch_video_info_and_upload

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


  class ScheduledWorker
    include MTSUtils::All

    def auto_query_loop
      if Delayed::Job.where(:queue => Settings.aliyun.mts.scheduled_queue).size <= 1
        MTSWorker::ScheduledWorker.auto_query_loop()
      end
      query_mini_transcoding_jobs
    end

    handle_asynchronously :auto_query_loop, :queue => Settings.aliyun.mts.scheduled_queue, :run_at => Proc.new { 5.seconds.from_now }

    def query_mini_transcoding_jobs
      jobs = MiniTranscodeJob.not_finished
      job_map = Hash[jobs.collect { |j| [j.job_id, j] }]
      job_ids = jobs.map { |j| j.job_id }
      job_ids.each_slice(10).each do |ids|
        request_id, result_list, not_exist_list = query_job_list(ids)
        result_list.each do |result|
          case result.state
            when MTSUtils::Status::TRANSCODING
              job_map[result.job_id].status = MtsJob::STATUS_PROCESSING
              job_map[result.job_id].percent = result.percent
            when MTSUtils::Status::TRANSCODE_SUCCESS
              job_map[result.job_id].status = MtsJob::STATUS_FINISHED
              #TODO

            when MTSUtils::Status::TRANSCODE_FAIL
              job_map[result.job_id].status = MtsJob::STATUS_FAILED
              job_map[result.job_id].code = result.code
              job_map[result.job_id].message = result.message
            when MTSUtils::Status::TRANSCODE_CANCELLED
              job_map[result.job_id].status = MtsJob::STATUS_CANCELD
          end
          job_map[result.job_id].save!
        end
        not_exist_list.each do |str|
          job_map[str].status = MtsJob::STATUS_MISSING
        end
      end
    end
  end
end