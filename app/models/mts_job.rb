class MtsJob < ActiveRecord::Base

  STATUS_PROCESSING = 1
  STATUS_FINISHED = 2

  def initialize(request_id)
    super()
    self.request_id = request_id
    self.status = STATUS_PROCESSING
  end
end

