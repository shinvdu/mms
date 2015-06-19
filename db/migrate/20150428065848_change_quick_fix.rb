class ChangeQuickFix < ActiveRecord::Migration
  def change
    change_column :transcodings, :video_codec,  :string

  end
end
