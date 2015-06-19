class CreateStatisticsDailyFlowStats < ActiveRecord::Migration
  def change
    create_table :statistics_daily_flow_stats do |t|
      t.references :user, index: true, foreign_key: true
      t.date :date
      t.integer :amount

      t.timestamps null: false
    end
  end
end
