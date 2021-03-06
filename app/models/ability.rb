class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.root?
      can :manage, :all
      cannot :access, :own_company
      cannot :access, VideoList
      return
    end

    # TODO add ability control
    can :access, :admin_page      if user.system_admin? || user.helper? ||  user.company_owner? || user.company_admin?
    can :access, :user_account    if user.system_admin?
    can :access, :company_account if user.system_admin?
    can :access, :own_company     if                                        user.company_owner? || user.company_admin?
    can :check, VideoProductGroup if user.system_admin? || user.helper?
    can :manage, VideoList        if                                        user.company_owner? || user.company_admin?


    can :manage, WaterMarkTemplate   unless                                                                              user.company_member?
    can :manage, Transcoding         unless                                                                              user.company_member?
    can :manage, TranscodingStrategy unless                                                                              user.company_member?
    can :manage, Advertise           unless                                                                              user.company_member?
    can :manage, Player              unless                                                                              user.company_member?


    Settings.video_privilege.keys.each do |pri|
      instance_eval <<-METHOD, __FILE__, __LINE__ + 1
        can :#{pri}, UserVideo do |user_video|
          user_video.creator == user || user_video.owner == user || (user.company_admin? && user.owner == user_video.owner) ? true :
          user_video.video_list && user_video.video_list.video_list_privileges.where(:user => user, :can_#{pri} => true).present?
        end
        can :#{pri}, VideoProductGroup do |group|
          group.creator == user || group.owner == user || (user.company_admin? && user.owner == group.owner) ? true :
          group.video_list && group.video_list.video_list_privileges.where(:user => user, :can_#{pri} => true).present?
        end
      METHOD
    end

    can :access, Company do |company|
      user.company_owner? && user.company == company
    end
    # can :manage, :all

    # The first argument to `can` is the action you are giving the user
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
