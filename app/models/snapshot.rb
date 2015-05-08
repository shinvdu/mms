class Snapshot < ActiveRecord::Base
  belongs_to :video_detail
  belongs_to :video_product_group

  include MTSWorker::SnapshotWorker

  module STATUS
    PROCESSING = 10
    FINISHED = 20
    FAILED = 99
  end

  def get_full_url
    "#{Settings.aliyun.oss.download_proxy}#{Settings.aliyun.oss.public_bucket}.#{Settings.aliyun.oss.host}/#{self.uri}"
  end

  def FINISHED?
    self.status == STATUS::FINISHED
  end
end

#------------------------------------------------------------------------------
# Snapshot
#
# Name                   SQL Type             Null    Default Primary
# ---------------------- -------------------- ------- ------- -------
# id                     int(11)              false           true   
# uri                    varchar(255)         true            false  
# status                 int(11)              true    10      false  
# video_detail_id        int(11)              true            false  
# time                   float                true            false  
# created_at             datetime             false           false  
# updated_at             datetime             false           false  
# video_product_group_id int(11)              true            false  
#
#------------------------------------------------------------------------------
