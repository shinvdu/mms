class ScheduledWorker
  include MTSWorker::Scheduled
  include LocalVideoWorker::Scheduled

  def mts_query_loop
    logger.info 'Start mts query loop'
    if Delayed::Job.where(:queue => Settings.aliyun.mts.scheduled_queue, :locked_by => nil).size <= 1
      mts_query_loop
    end
    safe_exception do
      query_transcoding_jobs
    end
    safe_exception do
      query_snapshot_jobs
    end
    safe_exception do
      query_meta_info_jobs
    end
  end

  handle_asynchronously :mts_query_loop, :queue => Settings.aliyun.mts.scheduled_queue, :run_at => Proc.new { 5.seconds.from_now }

  def local_video_loop
    logger.info 'Start local video loop'
    if Delayed::Job.where(:queue => Settings.file_server.video_cut_scheduled_queue, :locked_by => nil).size <= 1
      local_video_loop
    end
    # safe_exception do
    #   process_video_product_task
    # end
  end

  handle_asynchronously :local_video_loop, :queue => Settings.file_server.video_cut_scheduled_queue, :run_at => Proc.new { 5.seconds.from_now }

  def safe_exception
    begin
      yield
    rescue Exception => e
      puts e, e.backtrace
    end
  end

  def logger
    Delayed::Worker.logger
  end
end