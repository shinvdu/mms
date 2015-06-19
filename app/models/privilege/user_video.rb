module Privilege
  module UserVideoWithPrivilege
    def self.included(base)
      base.class_eval do
        scope :visible, ->(user) do
          if user.company_member?
            joins(:video_list => [:video_list_privileges, :owner]).where(
                :owner => user.owner,
                :video_lists => {:owner_id => user.owner},
                :video_list_privileges => {:user_id => user})
          else
            where(:owner => user.owner)
          end
        end
      end
    end
  end
end
