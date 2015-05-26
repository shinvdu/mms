module VideoListsHelper
  def has_video_privilege(privilege_users, member, privilege)
    return false if privilege_users.exclude? member
    privilege_users[member]["can_#{privilege}"]
  end
end
