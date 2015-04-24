json.array!(@advertise_resources) do |advertise_resource|
  json.extract! advertise_resource, :id, :name, :user_id, :file_type, :ad_type, :filesize, :uri, :ad_word, :data
  json.url advertise_resource_url(advertise_resource, format: :json)
end
