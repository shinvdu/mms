json.array!(@user) do |user|
  json.extract! user, :uid, :nicename, :birthday
  json.url user_url(user, format: :json)
end
