class User < ActiveRecord::Base
    self.primary_key = "uid"
    has_one :account
    has_many :user_videos, :foreign_key => :owner_id

end

#------------------------------------------------------------------------------
# User
#
# Name              SQL Type             Null    Default Primary
# ----------------- -------------------- ------- ------- -------
# uid               int(11)              false           true   
# nicename          varchar(255)         true            false  
# role              int(11)              true            false  
# sex               int(11)              true            false  
# really_name       int(11)              true            false  
# birthday          datetime             true            false  
# signature         varchar(255)         true            false  
# avar              int(11)              true            false  
# location          varchar(255)         true            false  
# self_introduction varchar(255)         true            false  
# token             varchar(255)         true            false  
# scret_key         varchar(255)         true            false  
# mobile            varchar(255)         true            false  
# wechat            varchar(255)         true            false  
# qq                varchar(255)         true            false  
# weibo             varchar(255)         true            false  
# twitter_id        varchar(255)         true            false  
# facebook          varchar(255)         true            false  
# website           varchar(255)         true            false  
# note              varchar(255)         true            false  
# created_at        datetime             false           false  
# updated_at        datetime             false           false  
#
#------------------------------------------------------------------------------
