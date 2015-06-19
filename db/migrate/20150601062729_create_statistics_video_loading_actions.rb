class CreateStatisticsVideoLoadingActions < ActiveRecord::Migration
  def change
    create_table :statistics_video_loading_actions do |t|
      t.references :user, index: true, foreign_key: true
      t.references :video_detail, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
