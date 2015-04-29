class VideoProductGroupTaskGroup < LocalTaskGroup
  belongs_to :target, :class_name => 'VideoProductGroup'
  before_save :default_values

  def default_values
    self.status ||= STATUS::NOT_STARTED
  end
end

#------------------------------------------------------------------------------
# VideoProductGroupTaskGroup
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
