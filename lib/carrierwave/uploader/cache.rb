module CarrierWave::Uploader::Cache
  def full_cache_path
    Rails.root.join('public', cache_dir, cache_name)
  end
end