json.array!(@user) do |user|
  json.extract! user, :uid, :nickname, :birthday
  json.url user_url(user, format: :json)
end
