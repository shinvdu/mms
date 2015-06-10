class OneTimeToken < ActiveRecord::Base
  belongs_to :cache_form

  def self.do_create(form)
    ret = self.create(
        :token => UUIDTools::UUID.random_create.to_s,
        :used => false,
        :cache_form => form,
        :expire_time => Settings.file_server.token_expire_seconds.seconds.from_now
    )
  end

  def self.validate(token)
    arel = OneTimeToken.arel_table
    OneTimeToken.where(:token => t.token, :used => false).where(arel[:expire_time].gteq(Time.now)).update_all(:used => true)
  end
end
