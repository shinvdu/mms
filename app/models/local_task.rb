class LocalTask < ActiveRecord::Base
  belongs_to :local_task_group
  scope :not_finished, -> { where(['status in (?)', STATUS::NOT_STARTED]) }
  scope :failed, -> { where(['status in (?)', STATUS::FAILED]) }

  module STATUS
    NOT_STARTED = 10
    PROCESSING = 20
    FINISHED = 30
    FAILED = 99
  end
end

#------------------------------------------------------------------------------
# LocalTask
#
# Name                SQL Type             Null    Default Primary
# ------------------- -------------------- ------- ------- -------
# id                  int(11)              false           true   
# status              int(11)              true            false  
# target_id           int(11)              true            false  
# finish_time         datetime             true            false  
# message             varchar(255)         true            false  
# prediction_time     datetime             true            false  
# percent             int(11)              true            false  
# local_task_group_id int(11)              true            false  
# dependency_id       int(11)              true            false  
# created_at          datetime             false           false  
# updated_at          datetime             false           false  
# type                varchar(255)         true            false  
#
#------------------------------------------------------------------------------
