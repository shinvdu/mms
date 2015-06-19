json.array!(@tags) do |tag|
  json.extract! tag, :id, :name, :user_id, :desc, :note
  json.url tag_url(tag, format: :json)
end
