FactoryGirl.define do
	factory :video_detail do
		uuid "c54ae49f-aed8-46c6-8834-1566a3c4d626"
		uri "video/c54ae49f-aed8-46c6-8834-1566a3c4d626/c54ae49f-aed8-46c6-8834-1566a3c4d626.mp4"
		format "mov,mp4,m4a,3gp,3g2,mj2"
		md5 "091a10970384b2b2e1a1a031078fc1cd"
		rate 404
		size 17436067
		duration 344.42
		status 50
		# user_video_id 1
		width 480
		height 320
		fps 30
		# transcoding_id 1
		fragment false
		video_codec "h264 (Constrained Baseline) (avc1 / 0x31637661)"
		audio_codec "aac (LC) (mp4a / 0x6134706D)"
		resolution "480x320"
		public false
		public_video nil
		private_video "c54ae49f-aed8-46c6-8834-1566a3c4d626.mp4"
	end

end
