class EnabledWaterMark < ActiveRecord::Base
  belongs_to :user
  belongs_to :water_mark_template
end
