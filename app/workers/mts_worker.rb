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
      create_minimal_video_job(self)
      self.status = UserVideo::STATUS_PRETRANSCODING
      # TODO get MD5 for original video
    end

    handle_asynchronously :fetch_video_info_and_upload

    def create_fetch_video_info_job(video_detail)
      request_id, meta_info_job = submit_meta_info_job(Settings.aliyun.oss.bucket, video_detail.uri)
      MetaInfoJob.new(meta_info_job.job_id, self).save!
    end

    def create_minimal_video_job(user_video)
      video_detail = user_video.original_video
      output_object_uri = video_detail.uri.split('.').insert(-2, Settings.aliyun.oss.mini_suffix).join('.')
      request_id, job_result = submit_job(Settings.aliyun.oss.bucket,
                                          video_detail.uri,
                                          output_object_uri,
                                          Settings.aliyun.mts.mini_template_id,
                                          Settings.aliyun.mts.pipeline_id)
      if job_result.success
        mini_video_detail = video_detail.dup
        user_video.mini_video = mini_video_detail
        mini_video_detail.user_video = video_detail.user_video
        mini_video_detail.uri = output_object_uri
        mini_video_detail.video = nil
        mini_video_detail.save!
        user_video.save!
        MiniTranscodeJob.new(job_result.job.job_id, self).save!
      end
    end
  end


  class ScheduledWorker
    include MTSUtils::All

    def auto_query_loop
      if Delayed::Job.where(:queue => Settings.aliyun.mts.scheduled_queue).size <= 1
        auto_query_loop
      end
      begin
        query_mini_transcoding_jobs
      rescue Exception => e
        puts e, e.backtrace
      end
      begin
        query_meta_info_list_job
      rescue Exception => e
        puts e, e.backtrace
      end
    end

    handle_asynchronously :auto_query_loop, :queue => Settings.aliyun.mts.scheduled_queue, :run_at => Proc.new { 5.seconds.from_now }

    def query_meta_info_list_job
      jobs = MetaInfoJob.not_finished
      job_map = Hash[jobs.collect { |j| [j.job_id, j] }]
      job_ids = jobs.map { |j| j.job_id }
      job_ids.each_slice(10).each do |ids|
        request_id, result_list, not_exist_list = query_job_list(ids)
        puts result_list
        result_list.each do |result|
          job = job_map[result.job_id]
          case result.state
            when MTSUtils::Status::ANALYZING
              job.status = MtsJob::STATUS::PROCESSING
            when MTSUtils::Status::SUCCESS
              job.status = MtsJob::STATUS::FINISHED
              job.finish_time = Time.now

              user_video = job.target
              original_video = user_video.original_video
              properties = result.properties

              user_video.width = properties.width
              user_video.height = properties.height
              user_video.duration = properties.duration
              original_video.width = user_video.width
              original_video.height = user_video.height
              original_video.duration = user_video.duration
              original_video.fps = properties.fps
              original_video.rate = properties.bitrate
              original_video.size = properties.file_size
              original_video.format = properties.file_format
            when MTSUtils::Status::FAIL
              job.status = MtsJob::STATUS::FAILED
              job.code = result.code
              job.message = result.message
            when MTSUtils::Status::TRANSCODE_CANCELLED
              job.status = MtsJob::STATUS::CANCELED
          end
          job.save!
        end
        not_exist_list.each do |str|
          job_map[str].status = MtsJob::STATUS::MISSING
          job_map[str].save!
        end
      end
    end

    def query_mini_transcoding_jobs
      jobs = MiniTranscodeJob.not_finished
      job_map = Hash[jobs.collect { |j| [j.job_id, j] }]
      job_ids = jobs.map { |j| j.job_id }
      job_ids.each_slice(10).each do |ids|
        request_id, result_list, not_exist_list = query_job_list(ids)
        puts result_list
        result_list.each do |result|
          job = job_map[result.job_id]
          case result.state
            when MTSUtils::Status::TRANSCODING
              job.status = MtsJob::STATUS::PROCESSING
              job.percent = result.percent
            when MTSUtils::Status::TRANSCODE_SUCCESS
              job.status = MtsJob::STATUS::FINISHED
              job.finish_time = Time.now
              user_video = job.target
              user_video.status = UserVideo::STATUS_GOT_LOW_RATE
              user_video.mini_video.uri = user_video.original_video.uri.split('.').insert(-2, Settings.aliyun.oss.mini_suffix).join('.')
              user_video.save!
            when MTSUtils::Status::TRANSCODE_FAIL
              job.status = MtsJob::STATUS::FAILED
              job.code = result.code
              job.message = result.message
            when MTSUtils::Status::TRANSCODE_CANCELLED
              job.status = MtsJob::STATUS::CANCELED
          end
          job.save!
        end
        not_exist_list.each do |str|
          job_map[str].status = MtsJob::STATUS::MISSING
          job_map[str].save!
        end
      end
    end
  end
end