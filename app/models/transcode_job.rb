class TranscodeJob < MTSJob
  # belongs_to :target, :class_name => 'VideoProduct', :foreign_key => :target_id
  #
  # def initialize(job_id, video_product)
  #   super(job_id)
  #   self.target = video_product
  # end
end
