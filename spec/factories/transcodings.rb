FactoryGirl.define do
	factory :transcoding do
		name "transform template"
		# user_id 2
		container "mp4"
		video_profile "high"
		video_preset  "slow"
		audio_codec "aac"
		audio_samplerate 44100
		audio_bitrate 128
		width nil
		height 720
		video_codec "H.264"
		video_bitrate 1000
		video_crf nil
		video_fps 25
		video_gop 250
		video_scanmode "progressive"
		video_bufsize 6000
		video_maxrate nil
		video_bitrate_bnd_max nil
		audio_channels 2
		state nil
		aliyun_template_id "ca5576930566d93344c3c2c0441f6987"
		video_bitrate_bnd_min nil
		disabled false
		disable_time nil
		share false
		special_template 0
		creator_id 0
	end

end
