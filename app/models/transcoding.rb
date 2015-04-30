class Transcoding < ActiveRecord::Base
  belongs_to :user
  has_many :transcoding_strategy_relationship
  scope :visiable, -> (user) { where(['user_id in (?, ?)', Settings.admin_id, user.uid]) }

  include MTSWorker::TranscodingWorker
end

#------------------------------------------------------------------------------
# Transcoding
#
# Name                  SQL Type             Null    Default Primary
# --------------------- -------------------- ------- ------- -------
# id                    int(11)              false           true   
# name                  varchar(255)         true            false  
# user_id               int(11)              true            false  
# container             varchar(255)         true            false  
# video_profile         varchar(255)         true            false  
# video_preset          varchar(255)         true            false  
# audio_codec           varchar(255)         true            false  
# audio_samplerate      int(11)              true            false  
# audio_bitrate         int(11)              true            false  
# video_line_scan       int(11)              true            false  
# h_w_percent           int(11)              true            false  
# width                 int(11)              true            false  
# height                int(11)              true            false  
# data                  text                 true            false  
# created_at            datetime             false           false  
# updated_at            datetime             false           false  
# video_codec           varchar(255)         true            false  
# video_bitrate         int(11)              true            false  
# video_crf             int(11)              true            false  
# video_fps             int(11)              true            false  
# video_gop             int(11)              true            false  
# video_scanmode        varchar(255)         true            false  
# video_bufsize         int(11)              true            false  
# video_maxrate         int(11)              true            false  
# video_bitrate_bnd_max int(11)              true            false  
# audio_channels        int(11)              true            false  
# state                 varchar(255)         true            false  
# aliyun_template_id    varchar(255)         true            false  
# video_bitrate_bnd_min int(11)              true            false  
# disabled              int(11)              true            false  
# share                 tinyint(1)           true            false  
#
#------------------------------------------------------------------------------
