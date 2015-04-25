class MetaInfoJob < MtsJob
  belongs_to :target, :class_name => 'UserVideo', :foreign_key => :target_id

  def initialize(job_id, user_video)
    super(job_id)
    self.target = user_video
  end
end
