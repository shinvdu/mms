class CreateStatisticsDailySpaceStats < ActiveRecord::Migration
  def change
    create_table :statistics_daily_space_stats do |t|
      t.references :user, index: true, foreign_key: true
      t.date :date
      t.integer :user_video_amount
      t.integer :mkv_video_amount
      t.integer :product_amount

      t.timestamps null: false
    end
  end
end
