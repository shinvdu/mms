json.array!(@water_mark_templates) do |water_mark_template|
  json.extract! water_mark_template, :id, :owner_id, :creator_id, :name, :width, :height, :refer_pos, :text, :img
  json.url water_mark_template_url(water_mark_template, format: :json)
end
