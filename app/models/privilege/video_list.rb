module Privilege
  module VideoListWithPrivilege
    def self.included(base)
      base.class_eval do
        scope :visible, ->(user) do
          if user.company_member?
            joins(:video_list_privileges, :owner).where(
                :owner => user.owner,
                :video_list_privileges => {:user_id => user})
          else
            where(:owner => user.owner)
          end
        end
        scope :uploadable, ->(user) do
          if user.company_member?
            visible(user).where(:video_list_privileges => {:can_upload => true})
          else
            visible(user)
          end
        end
      end
    end
  end
end

