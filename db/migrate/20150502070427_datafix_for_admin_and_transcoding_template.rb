class DatafixForAdminAndTranscodingTemplate < ActiveRecord::Migration
  def up
    account = Account.new :id => 1,
                          :username => Settings.default_admin.username,
                          :email => Settings.default_admin.email,
                          :password => Settings.default_admin.password,
                          :password_confirmation => Settings.default_admin.password
    account.create_user :nickname => 'admin'
    account.save!

    Transcoding.create! :id => 1,
                        :name => 'minimal-template',
                        :user_id => 1,
                        :container => 'mp4',
                        :video_profile => 'baseline',
                        :video_preset => 'fast',
                        :audio_codec => 'aac',
                        :audio_samplerate => '32000',
                        :audio_bitrate => '64',
                        :width => nil,
                        :height => nil,
                        :video_codec => 'H.264',
                        :video_bitrate => 100,
                        :video_crf => nil,
                        :video_fps => 24,
                        :video_gop => 250,
                        :video_scanmode => 'interlaced',
                        :video_bufsize => 1000,
                        :video_maxrate => 200,
                        :video_bitrate_bnd_max => 1000,
                        :audio_channels => 2,
                        :state => 'Normal',
                        :video_bitrate_bnd_min => 10,
                        :aliyun_template_id => Settings.aliyun.mts.mini_template_id,
                        :share => false
  end
end



