class MtsJob < ActiveRecord::Base
  scope :not_finished, -> { where(['status in (?, ?)', STATUS::SUBMITTED, STATUS::PROCESSING]) }

  module STATUS
    SUBMITTED = 1
    PROCESSING = 2
    FINISHED = 3
    CANCELED = 4
    FAILED = 5
    MISSING = 6
  end

  def initialize(job_id)
    super()
    self.job_id = job_id
    self.status = STATUS::SUBMITTED
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
# finish_time time                 true            false  
# message     varchar(255)         true            false  
# target_id   int(11)              true            false  
# created_at  datetime             false           false  
# updated_at  datetime             false           false  
# code        varchar(255)         true            false  
# percent     int(11)              true            false  
#
#------------------------------------------------------------------------------
