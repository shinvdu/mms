class TranscodingStrategyRelationship < ActiveRecord::Base
  belongs_to :user
  belongs_to :transcoding
  belongs_to :transcoding_tractegy
end

#------------------------------------------------------------------------------
# TranscodingStrategyRelationship
#
# Name                    SQL Type             Null    Default Primary
# ----------------------- -------------------- ------- ------- -------
# id                      int(11)              false           true   
# transcoding_id          int(11)              true            false  
# transcoding_strategy_id int(11)              true            false  
# user_id                 int(11)              true            false  
# created_at              datetime             false           false  
# updated_at              datetime             false           false  
#
#------------------------------------------------------------------------------
