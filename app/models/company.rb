class Company < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User'
end

#------------------------------------------------------------------------------
# Company
#
# Name        SQL Type             Null    Default Primary
# ----------- -------------------- ------- ------- -------
# id          int(11)              false           true   
# name        varchar(255)         true            false  
# owner_id    int(11)              true            false  
# description text                 true            false  
# created_at  datetime             false           false  
# updated_at  datetime             false           false  
#
#------------------------------------------------------------------------------
