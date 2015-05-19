json.array!(@notifications) do |notification|
  json.extract! notification, :id, :user_id, :is_read, :title, :target_id, :target_type
  json.url notification_url(notification, format: :json)
end
