class AddColumnsToCacheForm < ActiveRecord::Migration
  def change
    add_column :cache_forms, :type, :string
    add_column :cache_forms, :status, :integer, :default => CacheForm::STATUS::PREUPLOADED
  end
end
