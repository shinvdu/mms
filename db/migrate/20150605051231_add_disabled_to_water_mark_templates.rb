class AddDisabledToWaterMarkTemplates < ActiveRecord::Migration
  def change
    add_column :water_mark_templates, :disabled, :boolean, :default => false
  end
end
