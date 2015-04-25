class CreateTranscodings < ActiveRecord::Migration
  def change
    create_table :transcodings do |t|
      t.string :name
      t.integer :user_id
      t.string :output_format , :limit => 20
      t.string :quality, :limit => 20
      t.string :speed,  :limit => 20
      t.string :audio_encode,  :limit => 20
      t.string :audio_sample_rate,  :limit => 20
      t.string :audio_code_rate,  :limit => 20
      t.integer :video_line_scan,  :limit => 20
      t.integer :h_w_percent
      t.integer :width
      t.integer :height
      t.text :data

      t.timestamps null: false
    end
  end
end
