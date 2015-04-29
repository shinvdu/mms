class TranscodeJob < MtsJob
  belongs_to :target, :class_name => 'VideoDetail', :foreign_key => :target_id
end

#------------------------------------------------------------------------------
# TranscodeJob
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
