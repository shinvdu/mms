json.array!(@transcodings) do |transcoding|
  json.extract! transcoding, :id, :name, :user_id
  json.url transcoding_url(transcoding, format: :json)
end
