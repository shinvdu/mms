namespace :statistics do
  task :default => [:loading, :flow, :space]

  desc 'Statistics for daily loading'
  task :loading => :environment do
    include Statistics::Calculate
    safe_exception do
      calc_daily_loading
      logger.info 'calculate daily loading finished'
    end
  end

  desc 'Statistics for daily flow'
  task :flow => :environment do
    include Statistics::Calculate
    safe_exception do
      calc_daily_flow
      logger.info 'calculate daily flow finished'
    end
  end

  desc 'Statistics for daily space usage'
  task :space => :environment do
    include Statistics::Calculate
    safe_exception do
      calc_daily_space
      logger.info 'calculate daily space usage finished'
    end
  end

  desc 'remove statistics for last day'
  task :rollback => 'statistics:rollback:default'

  namespace :rollback do
    desc 'Rollback loading statistics'
    task :loading => :environment do
      include Statistics::Calculate
      safe_exception do
        rollback_loading
        logger.info 'rollback loading finished'
      end
    end

    desc 'Rollback flow statistics'
    task :flow => :environment do
      include Statistics::Calculate
      safe_exception do
        rollback_flow
        logger.info 'rollback flow finished'
      end
    end

    desc 'Rollback space usage statistics'
    task :space => :environment do
      include Statistics::Calculate
      safe_exception do
        rollback_space
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
