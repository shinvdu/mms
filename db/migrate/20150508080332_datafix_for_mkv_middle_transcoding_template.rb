class DatafixForMkvMiddleTranscodingTemplate < ActiveRecord::Migration
  def change
    Transcoding.create! :name => 'pre-mkv-middle-template',
                        :user_id => 1,
                        :container => 'mp4',
                        :video_profile => 'main',
                        :video_preset => 'slow',
                        :audio_codec => 'aac',
                        :audio_samplerate => '44100',
                        :audio_bitrate => 256,
                        :width => nil,
                        :height => nil,
                        :video_codec => 'H.264',
                        :video_bitrate => nil,
                        :video_crf => nil,
                        :video_fps => nil,
                        :video_gop => 20,
                        :video_scanmode => 'interlaced',
                        :video_bufsize => 128000,
                        :video_maxrate => 50000,
                        :video_bitrate_bnd_max => 50000,
                        :video_bitrate_bnd_min => 10,
                        :audio_channels => 2,
                        :state => 'Normal',
                        :aliyun_template_id => Settings.aliyun.mts.pre_mkv_middle_template_id,
                        :share => false,
                        :special_template => Transcoding::SPECIAL_TEMPLATE::PRE_MIDDLE_TEMPLATE
  end
end
