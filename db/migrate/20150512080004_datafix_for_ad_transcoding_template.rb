class DatafixForAdTranscodingTemplate < ActiveRecord::Migration
  def change
    Transcoding.create! :name => 'ad-template',
                        :user_id => 1,
                        :container => 'mp4',
                        :video_profile => 'main',
                        :video_preset => 'slow',
                        :audio_codec => 'aac',
                        :audio_samplerate => '44100',
                        :audio_bitrate => 128,
                        :width => nil,
                        :height => nil,
                        :video_codec => 'H.264',
                        :video_bitrate => nil,
                        :video_crf => 26,
                        :video_fps => nil,
                        :video_gop => 250,
                        :video_scanmode => 'interlaced',
                        :video_bufsize => 1000,
                        :video_maxrate => 1000,
                        :video_bitrate_bnd_max => nil,
                        :video_bitrate_bnd_min => nil,
                        :audio_channels => 2,
                        :state => 'Normal',
                        :aliyun_template_id => Settings.aliyun.mts.ad_template_id,
                        :share => false,
                        :special_template => Transcoding::SPECIAL_TEMPLATE::AD_TEMPLATE
  end
end
