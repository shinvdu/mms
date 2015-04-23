json.array!(@players) do |player|
  json.extract! player, :id, :name, :uid, :color, :logo, :logo_position, :autoplay, :share, :full_screen, :width, :height, :data
  json.url player_url(player, format: :json)
end
