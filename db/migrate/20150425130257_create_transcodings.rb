class CreateTranscodings < ActiveRecord::Migration
  def change
    create_table :transcodings do |t|
      t.string :name
      t.integer :user_id
      t.string :output_format 
      t.string :quality
      t.string :speed
      t.string :audio_encode
      t.string :audio_sample_rate
      t.string :audio_code_rate
      t.integer :video_line_scan
      t.integer :h_w_percent
      t.integer :width
      t.integer :height
      t.text :data

      t.timestamps null: false
    end
  end
end
