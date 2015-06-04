class AddColumnsToWaterMarkTemplates < ActiveRecord::Migration
  def change
    add_column :water_mark_templates, :aliyun_water_mark_template_id, :string
    add_column :water_mark_templates, :status, :integer, :default => 10
    add_column :water_mark_templates, :font_size, :integer
    add_column :water_mark_templates, :transparency, :integer
    add_column :water_mark_templates, :in_use, :boolean
  end
end
