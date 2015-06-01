module Statistics::Calculate
  def calc_daily_loading(beginning = nil, endding = nil)
    beginning ||= Time.now.yesterday.beginning_of_day
    endding ||= Time.now.yesterday.end_of_day
    User.all.each do |user|
      safe_exception do
        calc_daily_loading_for user, beginning, endding
      end
    end
  end

  def calc_daily_loading_for(user, beginning, endding)
    amount = VideoLoadingAction.count(:user => user, :created_at => beginning..endding)
    DailyLoadingStat.create(:user => user, :date => beginning.to_date, :amount => amount)
  end

  def calc_daily_flow(beginning = nil, endding = nil)
    beginning ||= Time.now.yesterday.beginning_of_day
    endding ||= Time.now.yesterday.end_of_day
    User.all.each do |user|
      safe_exception do
        calc_daily_flow_for user, beginning, endding
      end
    end
  end

  def calc_daily_flow_for(user, beginning, endding)
    amount = 0
    VideoLoadingAction.where(:user => user, :created_at => beginning..endding).each do |video_loading_action|
      amount += video_loading_action.video_detail.size
    end
    DailyFlowStat.create(:user => user, :date => beginning.to_date, :amount => amount)
  end

  def calc_daily_space(date = nil)
    date ||= Time.now.yesterday.to_date
    User.all.each do |user|
      safe_exception do
        calc_daily_space_for user, date
      end
    end
  end

  def calc_daily_space_for(user, date)
    stat = DailySpaceStat.new(:user => user, :date => date, :user_video_amount => 0, :mkv_video_amount => 0, :product_amount => 0)
    UserVideo.where(:creator => user).where(['created_at <= ?', date + 1]).each do |user_video|
      stat.user_video_amount += user_video.original_video.size
      stat.mkv_video_amount += user_video.mkv_video.size
    end
    VideoProductGroup.where(:creator => user).where(['created_at <= ?', date + 1]).each do |group|
      stat.product_amount += group.video_products.video_detail.size
    end
    stat.save!
  end

  def logger
    Log4r::Logger['statistics']
  end

  def safe_exception
    begin
      yield
    rescue Exception => e
      logger.error e
    end
  end
end
