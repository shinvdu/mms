class Company < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User'
  has_many :members, :class_name => 'User'

  def inactivate(operator)
    transaction do
      self.members.active.each do |user|
        user.inactivate(User::FROZEN_REASON::COMPANY_FROZEN, operator)
        user.save!
      end
    end
  end

  def activate
    transaction do
      self.members.each do |user|
        if user.frozeon_reason[:reason] == User::FROZEN_REASON::COMPANY_FROZEN
          user.activate
          user.save!
        end
      end
    end
  end
end

#------------------------------------------------------------------------------
# Company
#
# Name        SQL Type             Null    Default Primary
# ----------- -------------------- ------- ------- -------
# id          int(11)              false           true   
# name        varchar(255)         true            false  
# owner_id    int(11)              true            false  
# description text                 true            false  
# created_at  datetime             false           false  
# updated_at  datetime             false           false  
#
#------------------------------------------------------------------------------
