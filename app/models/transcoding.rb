class Transcoding < ActiveRecord::Base
  belongs_to :user
  has_many :transcoding_strategy_relationship
end

#------------------------------------------------------------------------------
# Transcoding
#
# Name              SQL Type             Null    Default Primary
# ----------------- -------------------- ------- ------- -------
# id                int(11)              false           true   
# name              varchar(255)         true            false  
# user_id           int(11)              true            false  
# output_format     varchar(255)         true            false  
# quality           varchar(255)         true            false  
# speed             varchar(255)         true            false  
# audio_encode      varchar(255)         true            false  
# audio_sample_rate varchar(255)         true            false  
# audio_code_rate   varchar(255)         true            false  
# video_line_scan   int(11)              true            false  
# h_w_percent       int(11)              true            false  
# width             int(11)              true            false  
# height            int(11)              true            false  
# data              text                 true            false  
# created_at        datetime             false           false  
# updated_at        datetime             false           false  
#
#------------------------------------------------------------------------------
