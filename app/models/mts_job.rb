class MtsJob < ActiveRecord::Base
  scope :not_finished, -> { where(['status in (?, ?)', STATUS_SUBMITTED, STATUS_PROCESSING]) }

  STATUS_SUBMITTED = 1
  STATUS_PROCESSING = 2
  STATUS_FINISHED = 3
  STATUS_CANCELD = 4
  STATUS_FAILED = 5
  STATUS_MISSING = 6

  def initialize(job_id)
    super()
    self.job_id = job_id
    self.status = STATUS_SUBMITTED
  end
end

