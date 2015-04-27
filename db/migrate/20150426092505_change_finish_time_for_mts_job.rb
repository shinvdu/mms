class ChangeFinishTimeForMtsJob < ActiveRecord::Migration
  def change
    change_column :mts_jobs, :finish_time,  :datetime
  end
end
