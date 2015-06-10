class CacheForm < ActiveRecord::Base
  belongs_to :user

  module STATUS
    PREUPLOADED = 10
    UPLOADED = 20
    PROCESSED = 30
    PROCESS_ERROR = 99
  end

  def process(**p)
    init_params p
    begin
      process_data
    rescue Exception => e
      self.update_attribute(:status, STATUS::PROCESS_ERROR)
      raise e
    end
  end
end
