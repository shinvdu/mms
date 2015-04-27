class VideoFragmentTask < LocalTask
  belongs_to :target, :class_name => 'VideoProductFragment'
  belongs_to :dependency, :class_name => 'VideoDetail'

  def initialize(group, target, dependency)
    self.local_task_group = group
    self.target = target
    self.dependency = dependency
  end

  def process

  end
end

#------------------------------------------------------------------------------
# VideoFragmentTask
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
#
#------------------------------------------------------------------------------
