class ChangeMiniAndMiddleToSpecialOnTranscodings < ActiveRecord::Migration
  def change
    add_column :transcodings, :special_template, :integer, default: Transcoding::SPECIAL_TEMPLATE::NONE
    Transcoding.reset_column_information
    Transcoding.where(:mini => true).each do |t|
      t.update_attribute(:special_template, Transcoding::SPECIAL_TEMPLATE::MINI_TEMPLATE)
    end
    remove_column :transcodings, :mini
    remove_column :transcodings, :middle
  end
end
