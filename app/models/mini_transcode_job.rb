class MiniTranscodeJob < MtsJob
  belongs_to :target, :class_name => 'UserVideo', :foreign_key => :target_id

  def initialize(job_id, user_video)
    super(job_id)
    self.target = user_video
  end
end

#------------------------------------------------------------------------------
# MiniTranscodeJob
#
# Name        SQL Type             Null    Default Primary
# ----------- -------------------- ------- ------- -------
# id          int(11)              false           true   
# type        varchar(255)         true            false  
# job_id      varchar(255)         true            false  
# status      int(11)              true            false  
# finish_time timestamp            true            false  
# message     varchar(255)         true            false  
# target_id   int(11)              true            false  
# created_at  datetime             false           false  
# updated_at  datetime             false           false  
# code        varchar(255)         true            false  
# percent     int(11)              true            false  
#
#------------------------------------------------------------------------------
