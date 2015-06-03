module Statistics::Calculate
  include Statistics

  def calc_daily_loading(date = nil)
    date ||= Time.now.yesterday
    beginning = date.beginning_of_day
    ending = date.end_of_day
    User.all.each do |user|
      safe_exception do
        calc_daily_loading_for user, beginning, ending
      end
    end
  end

  def calc_daily_loading_for(user, beginning, ending)
    amount = VideoLoadingAction.count(:user => user, :created_at => beginning..ending)
    DailyLoadingStat.create(:user => user, :date => beginning.to_date, :amount => amount)
  end

  def calc_daily_flow(date = nil)
    date ||= Time.now.yesterday
    beginning = date.beginning_of_day
    ending = date.end_of_day
    User.all.each do |user|
      safe_exception do
        calc_daily_flow_for user, beginning, ending
      end
    end
  end

  def calc_daily_flow_for(user, beginning, ending)
    amount = 0
    VideoLoadingAction.where(:user => user, :created_at => beginning..ending).each do |video_loading_action|
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
    stat = DailySpaceStat.new(:user => user, :date => date,
                              :user_video_amount => 0,
                              :mkv_video_amount => 0,
                              :product_amount => 0)
    UserVideo.where(:creator => user).where(['created_at <= ?', date + 1]).each do |user_video|
      stat.user_video_amount += user_video.original_video.size if user_video.original_video
      stat.mkv_video_amount += user_video.mkv_video.size if user_video.mkv_video
    end
    VideoProductGroup.where(:creator => user).where(['created_at <= ?', date + 1]).each do |group|
      stat.product_amount += group.video_products
                                 .map { |product| (product.video_detail && product.video_detail.size) || 0 }
                                 .reduce { |s, size| s + size } || 0
    end
    stat.save!
  end

  ############################################################################
  ## rollback
  ############################################################################

  def rollback_loading(date = nil)
    date ||= Time.now.yesterday.to_date
    DailyLoadingStat.where(['date >= ?', date]).delete_all
  end

  def rollback_flow(date = nil)
    date ||= Time.now.yesterday.to_date
    DailyFlowStat.where(['date >= ?', date]).delete_all
  end

  def rollback_space(date = nil)
    date ||= Time.now.yesterday.to_date
    DailySpaceStat.where(['date >= ?', date]).delete_all
  end
end
