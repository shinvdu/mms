json.array!(@advertise_strategies) do |advertise_strategy|
  json.extract! advertise_strategy, :id, :name, :user_id, :front_ad, :end_ad, :pause_ad, :float_ad, :scroll_ad, :data
  json.url advertise_strategy_url(advertise_strategy, format: :json)
end
