module Privilege
  def self.included(base)
    base.class_eval do
      scope :visible, -> (user){ where(:owner => user.owner)} if self.methods.exclude? :visible
      privilege_file_path = File.join(Rails.root, "app/models/privilege/#{base.name.underscore}.rb")
      return unless File.exist? privilege_file_path
      require_dependency privilege_file_path
      send :include, "privilege/#{base.name.underscore}_with_privilege".camelize.constantize
    end
  end
end

