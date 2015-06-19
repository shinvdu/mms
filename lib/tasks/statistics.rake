namespace :statistics do
  task :default => [:loading, :flow, :space]

  desc 'Statistics for daily loading'
  task :loading => :environment do
    include Statistics::Calculate
    dates = (1..(ENV['days'] || 1).to_i).to_a.reverse.map { |d| d.days.ago.to_date }
    safe_exception do
      dates.each { |date| calc_daily_loading(date) }
      logger.info 'calculate daily loading finished'
    end
  end

  desc 'Statistics for daily flow'
  task :flow => :environment do
    include Statistics::Calculate
    dates = (1..(ENV['days'] || 1).to_i).to_a.reverse.map { |d| d.days.ago.to_date }
    safe_exception do
      dates.each { |date| calc_daily_flow(date) }
      logger.info 'calculate daily flow finished'
    end
  end

  desc 'Statistics for daily space usage'
  task :space => 'rollback:space' do
    include Statistics::Calculate
    dates = (1..(ENV['days'] || 1).to_i).to_a.reverse.map { |d| d.days.ago.to_date }
    safe_exception do
      dates.each { |date| calc_daily_space(date) }
      logger.info 'calculate daily space usage finished'
    end
  end

  desc 'remove statistics for last day'
  task :rollback => 'statistics:rollback:default'

  namespace :rollback do
    desc 'Rollback loading statistics'
    task :loading => :environment do
      include Statistics::Calculate
      date = (ENV['days'] || 1).to_i.days.ago.to_date
      safe_exception do
        rollback_loading(date)
        logger.info 'rollback loading finished'
      end
    end

    desc 'Rollback flow statistics'
    task :flow => :environment do
      include Statistics::Calculate
      date = (ENV['days'] || 1).to_i.days.ago.to_date
      safe_exception do
        rollback_flow(date)
        logger.info 'rollback flow finished'
      end
    end

    desc 'Rollback space usage statistics'
    task :space => :environment do
      include Statistics::Calculate
      date = (ENV['days'] || 1).to_i.days.ago.to_date
      safe_exception do
        rollback_space(date)
        logger.info 'rollback space usage finished'
      end
    end

    task :default => [:loading, :flow, :space]
  end
end

desc 'Do statistics'
task :statistics => 'statistics:default'

def safe_exception
  begin
    yield
  rescue Exception => e
    logger.error e
  end
end

def logger
  Log4r::Logger['statistics']
end
