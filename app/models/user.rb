class User < ActiveRecord::Base
    self.primary_key = "uid"
    has_one :account

end
