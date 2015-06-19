class CreateSnapshots < ActiveRecord::Migration
  def change
    create_table :snapshots do |t|
      t.string :uri
      t.integer :status, :default => Snapshot::STATUS::PROCESSING
      t.integer :video_detail_id
      t.float :time

      t.timestamps null: false
    end
  end
end
