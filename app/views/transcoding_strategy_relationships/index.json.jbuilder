json.array!(@transcoding_strategy_relationships) do |transcoding_strategy_relationship|
  json.extract! transcoding_strategy_relationship, :id, :transcoding_id, :transcoding_strategy_id, :user_id
  json.url transcoding_strategy_relationship_url(transcoding_strategy_relationship, format: :json)
end
