namespace :jobs do

  desc "Start scheduled delayed job"
  task :scheduled => :environment do
    worker = MTSWorker::ScheduledWorker.new
    worker.auto_query_loop
    puts 'succeed'
  end
end