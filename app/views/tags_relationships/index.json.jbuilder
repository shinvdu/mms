json.array!(@tags_relationships) do |tags_relationship|
  json.extract! tags_relationship, :id, :tag_id, :user_video_id
  json.url tags_relationship_url(tags_relationship, format: :json)
end
