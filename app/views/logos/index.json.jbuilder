json.array!(@logos) do |logo|
  json.extract! logo, :id, :name, , :uri, :width, :height, :filemime, :filesize, :origname
  json.url logo_url(logo, format: :json)
end
