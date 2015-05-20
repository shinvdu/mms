class Notification < ActiveRecord::Base
	belongs_to :user
	validates_uniqueness_of :user_id, :title, :target_id, :target_type
	def get_target_object
		tclass = Object.const_get(self.target_type)
		tclass.find_by_id(self.id)
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
