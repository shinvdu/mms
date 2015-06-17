class OneTimeToken < ActiveRecord::Base
  belongs_to :user
  belongs_to :cache_form
  # validates :user_id, presence: true
  def self.do_create(form)
    ret = self.create(
        :token => UUIDTools::UUID.random_create.to_s,
        :used => false,
        :cache_form => form,
        :expire_time => Settings.file_server.token_expire_seconds.seconds.from_now
    )
  end

  def self.create_token(user)
    ret = self.create(
      :user_id => user.id,
      :token => UUIDTools::UUID.random_create.to_s,
      :used => false,
      :expire_time => Settings.file_server.token_expire_seconds.seconds.from_now
      )
  end


  def self.validate(token)
    records = OneTimeToken.get_token_rows(token)
    if records.count > 0
       the_one = records.first
       the_one.used = true
       the_one.save
    else
       return false
    end
  end

  def self.get_token_rows(token)
    return records = OneTimeToken.where(:token => token, :used => false).where("expire_time >= ?",Time.now)    
  end

  def mark_as_used
      self.used = true
      self.save
  end
end
