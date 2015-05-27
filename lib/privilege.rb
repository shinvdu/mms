module Privilege
  def self.included(base)
    base.class_eval do
      privilege_file_path = File.join(Rails.root, "app/models/privilege/#{base.name.underscore}.rb")
      return unless File.exist? privilege_file_path
      require privilege_file_path
      send :include, "privilege/#{base.name.underscore}_with_privilege".camelize.constantize
    end
  end
end

