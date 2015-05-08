module MTSWorker
  module UserVideoWorker
    include MTSUtils::All

    def create_transcoding_video_job(transcoding = nil, public = false)
      job = self.original_video.create_transcoding_video_job(transcoding, public)
      self.mini_video = job.target if transcoding.nil? || transcoding.mini_transcoding?
      return
    end
  end

  module VideoDetailWorker
    include MTSUtils::All

    def create_transcoding_video_job(transcoding = nil, public = false)
      transcoding = Transcoding.find_mini_template if transcoding.nil?
      template_id = transcoding.aliyun_template_id
      suffix = transcoding.mini_transcoding? ? Settings.file_server.mini_suffix : transcoding.id.to_s
      output_object_uri = self.uri.split('.')[0..-2].push(suffix, transcoding.container).join('.')
      logger.debug 'create transcoding job'
      logger.debug "[template id: #{template_id}]"
      output_bucket = public ? Settings.aliyun.oss.public_bucket : Settings.aliyun.oss.private_bucket
      request_id, job_result = submit_job(self.bucket,
                                          self.uri,
                                          output_object_uri,
                                          template_id,
                                          Settings.aliyun.mts.pipeline_id,
                                          :output_bucket => output_bucket)
      if job_result.success
        transcoded_video_detail = VideoDetail.new.set_attributes_by_hash(self.copy_attributes)
        transcoded_video_detail.transcoding = transcoding if transcoding.present?
        transcoded_video_detail.uri = output_object_uri
        transcoded_video_detail.status = VideoDetail::STATUS::PROCESSING
        transcoded_video_detail.public = public
        transcoded_video_detail.save!
        # change carrierwave mounted column
        if public
          transcoded_video_detail.update_column(:public_video, File.basename(output_object_uri))
        else
          transcoded_video_detail.update_column(:private_video, File.basename(output_object_uri))
        end
        TranscodeJob.create(:job_id => job_result.job.job_id, :target => transcoded_video_detail)
      else
        logger.error 'create transcoding job failed!'
        raise 'create transcoding job failed!'
      end
    end

    def create_fetch_video_info_job
      request_id, meta_info_job = submit_meta_info_job(self.bucket, self.uri)
      MetaInfoJob.create(:job_id => meta_info_job.job_id, :target => self)
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

  module SnapshotWorker
    include MTSUtils::All

    def create_mts_job
      request_id, snapshot_job = submit_snapshot_job(self.video_detail.bucket, self.video_detail.uri, self.time.to_i, self.uri,
                                                     :output_bucket => Settings.aliyun.oss.public_bucket)
      if snapshot_job.state == MTSUtils::Status::SUCCESS || snapshot_job.state == MTSUtils::Status::SNAPSHOTING
        SnapshotJob.create!(:job_id => snapshot_job.job_id, :target => self)
      else
        self.status = Snapshot::STATUS::FAILED
      end
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

              video_detail = job.target
              properties = result.properties

              video_detail.width = properties.width
              video_detail.height = properties.height
              video_detail.duration = properties.duration
              video_detail.fps = properties.fps
              video_detail.rate = properties.bitrate
              video_detail.size = properties.file_size
              video_detail.format = properties.file_format
              video_detail.save!
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
              job.post_process
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

    def query_snapshot_jobs
      jobs = SnapshotJob.not_finished
      job_map = Hash[jobs.collect { |j| [j.job_id, j] }]
      job_ids = jobs.map { |j| j.job_id }
      job_ids.each_slice(10).each do |ids|
        request_id, result_list, not_exist_list = query_snapshot_job_list(ids)
        logger.debug result_list
        result_list.each do |result|
          job = job_map[result.job_id]
          logger.info "Checking for #{job.id}, status is #{result.state}"
          case result.state
            when MTSUtils::Status::SNAPSHOTING
              job.status = MtsJob::STATUS::PROCESSING
            when MTSUtils::Status::SUCCESS
              job.status = MtsJob::STATUS::FINISHED
              job.finish_time = Time.now
              snapshot = job.target
              snapshot.status = Snapshot::STATUS::FINISHED
              snapshot.save!
            when MTSUtils::Status::FAIL
              job.status = MtsJob::STATUS::FAILED
              job.code = result.code
              job.message = result.message
          end
          job.save!
        end
        not_exist_list.each do |str|
          job_map[str].status = MtsJob::STATUS::MISSING
          job_map[str].save!
          job_map[str].target.status = Snapshot::STATUS::FAILED
          job_map[str].target.save!
        end
      end
    end
  end
end