class CreateVideoListPrivileges < ActiveRecord::Migration
  def change
    create_table :video_list_privileges do |t|
      t.integer :user_id, index: true
      t.references :video_list, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

