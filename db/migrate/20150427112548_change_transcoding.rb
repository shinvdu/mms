class ChangeTranscoding < ActiveRecord::Migration
  def change
    add_column :transcodings, :video_codec, :integer
    rename_column :transcodings, :quality, :video_profile
    rename_column :transcodings, :speed, :video_preset
    rename_column :transcodings, :audio_encode, :audio_codec
    rename_column :transcodings, :audio_sample_rate, :audio_samplerate
    rename_column :transcodings, :audio_code_rate, :audio_bitrate
    add_column :transcodings, :video_bitrate, :integer
    add_column :transcodings, :video_crf, :integer
    add_column :transcodings, :video_fps, :integer
    add_column :transcodings, :video_gop, :integer
    add_column :transcodings, :video_scanmode, :string
    add_column :transcodings, :video_bufsize, :integer
    add_column :transcodings, :video_maxrate, :integer
    add_column :transcodings, :video_bitratebnd, :integer
    add_column :transcodings, :audio_channels, :integer
    change_column :transcodings, :audio_samplerate, :integer
    change_column :transcodings, :audio_bitrate, :integer
  end
end
