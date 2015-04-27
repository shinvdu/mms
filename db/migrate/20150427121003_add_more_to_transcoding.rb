class AddMoreToTranscoding < ActiveRecord::Migration
  def change
    rename_column :transcodings, :output_format, :container
    add_column :transcodings, :state, :string
    add_column :transcodings, :aliyun_template_id, :string
  end
end
