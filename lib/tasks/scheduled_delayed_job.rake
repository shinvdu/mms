namespace :jobs do

  desc "Start scheduled delayed job"
  task :scheduled => :environment do
    worker = ScheduledWorker.new
    worker.mts_query_loop
    puts 'succeed'
  end

  desc "Clear scheduled delayed job"
  task :scheduled_clear => :environment do
    Delayed::Job.where(:queue => Settings.aliyun.mts.scheduled_queue).delete_all
    Delayed::Job.where(:queue => Settings.file_server.video_cut_scheduled_queue).delete_all
  end
end