class VideoProductTask < LocalTask
  belongs_to :target, :class_name => 'VideoProduct'
end
