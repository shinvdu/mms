class LocalTaskGroup < ActiveRecord::Base
  module STATUS
    NOT_STARTED = 10
    PROCESSING = 20
    FINISHED = 30
  end
end

#------------------------------------------------------------------------------
# LocalTaskGroup
#
# Name            SQL Type             Null    Default Primary
# --------------- -------------------- ------- ------- -------
# id              int(11)              false           true   
# status          int(11)              true            false  
# target_id       int(11)              true            false  
# finish_time     datetime             true            false  
# message         varchar(255)         true            false  
# prediction_time datetime             true            false  
# percent         int(11)              true            false  
# created_at      datetime             false           false  
# updated_at      datetime             false           false  
# type            varchar(255)         true            false  
#
#------------------------------------------------------------------------------
