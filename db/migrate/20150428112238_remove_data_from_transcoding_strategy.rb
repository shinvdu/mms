class RemoveDataFromTranscodingStrategy < ActiveRecord::Migration
  def change
    remove_column :transcoding_strategies, :data, :string
  end
end
