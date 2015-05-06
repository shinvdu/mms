class MtsJob < ActiveRecord::Base
  scope :not_finished, -> { where(['status in (?, ?)', STATUS::SUBMITTED, STATUS::PROCESSING]) }

  module STATUS
    SUBMITTED = 10
    PROCESSING = 20
    FINISHED = 30
    CANCELED = 40
    FAILED = 50
    MISSING = 60
  end

  def post_process
    Rails.logger.info "post process, #{self.post_process_command}"
    eval self.post_process_command if self.post_process_command.present?
  end
end


#------------------------------------------------------------------------------
# MtsJob
#
# Name        SQL Type             Null    Default Primary
# ----------- -------------------- ------- ------- -------
# id          int(11)              false           true   
# type        varchar(255)         true            false  
# job_id      varchar(255)         true            false  
# status      int(11)              true            false  
# finish_time datetime             true            false  
# message     varchar(255)         true            false  
# target_id   int(11)              true            false  
# created_at  datetime             false           false  
# updated_at  datetime             false           false  
# code        varchar(255)         true            false  
# percent     int(11)              true            false  
#
#------------------------------------------------------------------------------
