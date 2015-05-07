class SnapshotJob < MtsJob
  belongs_to :target, :class_name => 'Snapshot', :foreign_key => :target_id
end
