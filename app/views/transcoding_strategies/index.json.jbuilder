json.array!(@transcoding_strategies) do |transcoding_strategy|
  json.extract! transcoding_strategy, :id, :name, :user_id, :data, :note
  json.url transcoding_strategy_url(transcoding_strategy, format: :json)
end
