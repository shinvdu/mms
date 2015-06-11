class CreateStatisticsDailyLoadingStats < ActiveRecord::Migration
  def change
    create_table :statistics_daily_loading_stats do |t|
      t.references :user, index: true, foreign_key: true
      t.date :date
      t.integer :amount

      t.timestamps null: false
    end
  end
end
