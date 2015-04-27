class ScheduledWorker
  include MTSWorker::Scheduled

  def mts_query_loop
    if Delayed::Job.where(:queue => Settings.aliyun.mts.scheduled_queue).size <= 1
      mts_query_loop
    end
    safe_exception do
      query_mini_transcoding_jobs
    end
    safe_exception do
      query_meta_info_list_job
    end
    # begin
    #   query_mini_transcoding_jobs
    # rescue Exception => e
    #   puts e, e.backtrace
    # end
    # begin
    #   query_meta_info_list_job
    # rescue Exception => e
    #   puts e, e.backtrace
    # end
  end

  handle_asynchronously :mts_query_loop, :queue => Settings.aliyun.mts.scheduled_queue, :run_at => Proc.new { 5.seconds.from_now }

  def local_video_loop

    if Delayed::Job.where(:queue => Settings.file_server.video_cut_scheduled_queue).size <= 1
      local_video_loop
    end
    safe_exception do
      puts 'ha'
    end
  end

  handle_asynchronously :local_video_loop, :queue => Settings.file_server.video_cut_scheduled_queue, :run_at => Proc.new { 5.seconds.from_now }

  def safe_exception
    begin
      yield
    rescue Exception => e
      puts e, e.backtrace
    end
  end
end