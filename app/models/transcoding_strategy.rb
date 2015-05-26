class TranscodingStrategy < ActiveRecord::Base
  belongs_to :user
  has_many :transcoding_strategy_relationships
  has_many :transcodings, :through => :transcoding_strategy_relationships, :source => :transcoding
  scope :visiable, -> (user) { where(['user_id = ? or share', user.uid]) }

  def update_transcodings(transcoding_ids, operator)
    transaction do
      self.transcoding_strategy_relationships.each do |relation|
        relation.destroy if transcoding_ids.exclude? relation.transcoding_id
      end
      existed_transcoding_ids = self.transcodings.map { |t| t.id }
      transcoding_ids.each do |transcoding_id|
        if existed_transcoding_ids.exclude? transcoding_id
          TranscodingStrategyRelationship.create(:transcoding_strategy => self, :transcoding_id => transcoding_id, :user_id => operator.id)
        end
      end
    end
  end
end

#------------------------------------------------------------------------------
# TranscodingStrategy
#
# Name       SQL Type             Null    Default Primary
# ---------- -------------------- ------- ------- -------
# id         int(11)              false           true   
# name       varchar(255)         true            false  
# user_id    int(11)              true            false  
# note       text                 true            false  
# created_at datetime             false           false  
# updated_at datetime             false           false  
# share      tinyint(1)           true            false  
#
#------------------------------------------------------------------------------
