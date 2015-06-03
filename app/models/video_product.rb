class VideoProduct < ActiveRecord::Base
  belongs_to :video_product_group
  has_many :video_product_fragments, -> { order('video_product_fragments.order') }
  belongs_to :video_detail
  belongs_to :transcoding

  module STATUS
    NOT_STARTED = 10
    WAIT_FOR_DEPENDENCY = 20
    DOWNLOADING = 30
    PROCESSING = 40
    UPLOADING = 50
    FINISHED = 60
  end

  def get_m3u8_file_path
    file_path = Rails.root.join(Settings.m3u8_dir, [self.video_product_group.id, self.id, 'm3u8'].join('.'))
    dir = File.dirname file_path
    FileUtils.mkdir_p dir if !File.exist? dir
    if !File.exist? file_path
      File.open file_path, 'w' do |file|
        file.puts '#EXTM3U'
        self.video_product_fragments.each_with_index do |fragment, idx|
          file.puts
          file.puts "#EXTINF:#{fragment.video_detail.duration}, vdo #{idx}"
          file.puts fragment.video_detail.get_full_url
        end
      end
    end
    file_path
  end

  def FINISHED?
    self.status == STATUS::FINISHED
  end

  ########################################################
  # asynchronous method
  ########################################################

  def produce!(dependent_video, video_fragments)
    fragments = []
    video_fragments.each_with_index do |frag, idx|
      product_fragment = VideoProductFragment.new(:video_product => self, :video_fragment => frag, :order => idx)
      product_fragment.produce(dependent_video)
      fragments.append product_fragment
    end

    self.status = VideoProduct::STATUS::FINISHED
    self.save!
  end

  def transcode_video(video_detail, transcoding)
    transcode_job = video_detail.create_transcoding_video_job(transcoding, true)
    transcode_job.post_process_command = "VideoProduct.find(#{self.id}).video_transcode_finished"
    transcode_job.save!
    self.video_detail = transcode_job.target
    self.save!
  end

  def publish_mp4!(video)
    self.video_detail = video.create_mp4_video
    if self.video_detail == video
      self.video_detail = video.load_local_file_to_public!
    else
      self.video_detail.public = true
      self.video_detail.load_local_file!
      self.video_detail.fetch_video_info
      self.video_detail.remove_local_file!
    end
    self.status = STATUS::FINISHED
    self.save!
  end

  def video_transcode_finished
    self.status = STATUS::FINISHED
    self.video_product_group.check_all_finished
    self.save!
  end

  def check_quanity()
    transcoding = self.transcoding 
    if transcoding.height
      quanity_desc = [transcoding.height, 'P'].join('')
    elsif transcoding.height.nil?
      video_detail = self.video_detail
      quanity_desc = [video_detail.height, 'P'].join('')
    end
    # if transcoding.width.nil? && transcoding.height.nil?
    #   video_detail = self.video_detail
    #   quanity_desc = [video_detail.height, 'P'].join('')
    # elsif transcoding.width && transcoding.height.nil?
    #   quanity_desc = ['H' , transcoding.width].join('')
    # elsif transcoding.width.nil? && transcoding.height
    #   quanity_desc = [transcoding.height, 'P'].join('')
    # end
    return quanity_desc
  end

end

#------------------------------------------------------------------------------
# VideoProduct
#
# Name                   SQL Type             Null    Default Primary
# ---------------------- -------------------- ------- ------- -------
# id                     int(11)              false           true   
# video_product_group_id int(11)              true            false  
# video_detail_id        int(11)              true            false  
# transcoding_id         int(11)              true            false  
# progress               int(11)              true            false  
# status                 int(11)              true    10      false  
# created_at             datetime             false           false  
# updated_at             datetime             false           false  
#
#------------------------------------------------------------------------------
