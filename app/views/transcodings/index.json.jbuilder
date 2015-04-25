json.array!(@transcodings) do |transcoding|
  json.extract! transcoding, :id, :name, :user_id, :output_format, :quality, :speed, :audio_encode, :audio_sample_rate, :audio_code_rate, :video_line_scan, :h_w_percent, :width, :height, :data
  json.url transcoding_url(transcoding, format: :json)
end
