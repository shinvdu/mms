module MTSWorker
  module UserVideoWorker
    include MTSUtils::All

    def fetch_video_info_and_upload
      video_detail = self.original_video
      video_detail.load_local_file(video_detail.get_full_path)
      # if video_detail.video_codec !=
      #
      # end
      self.status = UserVideo::STATUS::UPLOADED
      create_transcoding_video_job
      self.status = UserVideo::STATUS::PRETRANSCODING
    end

    handle_asynchronously :fetch_video_info_and_upload

    def create_fetch_video_info_job(video_detail)
      request_id, meta_info_job = submit_meta_info_job(Settings.aliyun.oss.bucket, video_detail.uri)
      MetaInfoJob.create(:job_id => meta_info_job.job_id, :target => self)
    end

    # def create_minimal_video_job
    #   video_detail = self.original_video
    #   output_object_uri = video_detail.uri.split('.').insert(-2, Settings.aliyun.oss.mini_suffix).join('.')
    #   request_id, job_result = submit_job(Settings.aliyun.oss.bucket,
    #                                       video_detail.uri,
    #                                       output_object_uri,
    #                                       Settings.aliyun.mts.mini_template_id,
    #                                       Settings.aliyun.mts.pipeline_id)
    #   if job_result.success
    #     mini_video_detail = video_detail.dup
    #     self.mini_video = mini_video_detail
    #     mini_video_detail.user_video = self
    #     mini_video_detail.uri = output_object_uri
    #     mini_video_detail.video = nil
    #     mini_video_detail.save!
    #     self.save!
    #     TranscodeJob.create(:job_id => job_result.job.job_id, :target => mini_video_detail)
    #   end
    # end

    def create_transcoding_video_job(transcoding = nil)
      video_detail = self.original_video
      transcoding = Transcoding.find(1) if transcoding.nil?
      template_id = transcoding.aliyun_template_id
      suffix = transcoding.id == 1 ? Settings.file_server.mini_suffix : transcoding.id.to_s
      output_object_uri = video_detail.uri.split('.').push(suffix, transcoding.container).join('.')
      logger.debug 'create transcoding job'
      logger.debug "[template id: #{template_id}]"
      request_id, job_result = submit_job(Settings.aliyun.oss.bucket,
                                          video_detail.uri,
                                          output_object_uri,
                                          template_id,
                                          Settings.aliyun.mts.pipeline_id)
      if job_result.success
        transcoded_video_detail = video_detail.dup
        self.mini_video = transcoded_video_detail if transcoding.mini_transcoding?
        transcoded_video_detail.transcoding = transcoding if transcoding.present?
        transcoded_video_detail.uri = output_object_uri
        transcoded_video_detail.status = VideoDetail::STATUS::PROCESSING
        transcoded_video_detail.save!
        # change carrierwave mounted column
        transcoded_video_detail.update_column(:video, File.basename(output_object_uri))
        self.save!
        TranscodeJob.create(:job_id => job_result.job.job_id, :target => transcoded_video_detail)
      end
    end
  end

  module TranscodingWorker
    include MTSUtils::All

    def upload_and_save!
      request_id, res_template = add_template(self)
      self.aliyun_template_id = res_template.id
      self.save!
      self
    end
  end

  module Scheduled
    include MTSUtils::All

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

    def query_transcoding_jobs
      jobs = TranscodeJob.not_finished
      job_map = Hash[jobs.collect { |j| [j.job_id, j] }]
      job_ids = jobs.map { |j| j.job_id }
      job_ids.each_slice(10).each do |ids|
        request_id, result_list, not_exist_list = query_job_list(ids)
        logger.debug result_list
        result_list.each do |result|
          job = job_map[result.job_id]
          logger.info "Checking for #{job.id}, status is #{result.state}"
          case result.state
            when MTSUtils::Status::TRANSCODING
              job.status = MtsJob::STATUS::PROCESSING
              job.percent = result.percent
            when MTSUtils::Status::TRANSCODE_SUCCESS
              job.status = MtsJob::STATUS::FINISHED
              job.finish_time = Time.now
              video_detail = job.target
              if video_detail.transcoding.mini_transcoding?
                user_video = video_detail.user_video
                user_video.status = UserVideo::STATUS::GOT_LOW_RATE
                user_video.save!
              end
              if video_detail.PROCESSING?
                video_detail.status = VideoDetail::STATUS::ONLY_REMOTE
              else
                video_detail.status = VideoDetail::STATUS::BOTH
              end
              video_detail.save!
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