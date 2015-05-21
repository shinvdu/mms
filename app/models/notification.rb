class Notification < ActiveRecord::Base
	belongs_to :user
	validates_uniqueness_of :user_id, :title, :target_id, :target_type
	def get_target_object
		tclass = Object.const_get(self.target_type)
		tclass.find_by_id(self.target_id)
	end

	def self.system_message(user_id, message, target_object)
		n = Notification.new
		n.user_id = user_id
		n.title = message
		n.target_id = target_object.id
		n.target_object = target_object.class
		n.save
	end
end


# +-------------+--------------+------+-----+---------+----------------+
# | Field       | Type         | Null | Key | Default | Extra          |
# +-------------+--------------+------+-----+---------+----------------+
# | id          | int(11)      | NO   | PRI | NULL    | auto_increment |
# | user_id     | int(11)      | YES  |     | NULL    |                |
# | is_read     | tinyint(1)   | YES  |     | NULL    |                |
# | title       | varchar(255) | YES  |     | NULL    |                |
# | target_id   | int(11)      | YES  |     | NULL    |                |
# | target_type | varchar(255) | YES  |     | NULL    |                |
# | created_at  | datetime     | NO   |     | NULL    |                |
# | updated_at  | datetime     | NO   |     | NULL    |                |
# +-------------+--------------+------+-----+---------+----------------+

#------------------------------------------------------------------------------
# Notification
#
# Name        SQL Type             Null    Default Primary
# ----------- -------------------- ------- ------- -------
# id          int(11)              false           true   
# user_id     int(11)              true            false  
# is_read     tinyint(1)           true            false  
# title       varchar(255)         true            false  
# target_id   int(11)              true            false  
# target_type varchar(255)         true            false  
# created_at  datetime             false           false  
# updated_at  datetime             false           false  
#
#------------------------------------------------------------------------------
