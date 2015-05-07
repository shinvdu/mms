class Snapshot < ActiveRecord::Base
  belongs_to :video_detail

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
