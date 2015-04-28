class VideoProductGroupTaskGroup < LocalTaskGroup
  belongs_to :target, :class_name => 'VideoProductGroup'
  before_save :default_values

  def default_values
    self.status ||= STATUS::NOT_STARTED
  end
end
