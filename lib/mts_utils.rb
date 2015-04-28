module MTSUtils
  def self.included(base)
    base.send(:include, Core)
  end

  module All
    def self.included(base)
      base.send(:include, MTSUtils::Core)
      base.send(:include, MTSUtils::MetaInfo)
      base.send(:include, MTSUtils::AnalysisJob)
      base.send(:include, MTSUtils::Job)
      base.send(:include, MTSUtils::Snapshot)
      base.send(:include, MTSUtils::Pipeline)
      base.send(:include, MTSUtils::Template)
      base.send(:include, MTSUtils::WaterMark)
    end
  end

  module Core
    require 'uuidtools'

    def generate_url(options = {})
      # TODO config
      @host = 'mts.aliyuncs.com'
      @aliyun_access_id = '1cnDtYk8fMS0lyoM'
      @aliyun_access_key = 'PR6H6WIq4gqun4BJ5bwWQQt5BUO5su'
      @SEPARATOR = '&'
      @EQUAL = '='
      @HTTP_METHOD = 'POST'
      paramaters = {
          'AccessKeyId' => @aliyun_access_id,
          # 'Action' => 'QueryMediaList',
          # 'MediaIds' => '88c6ca184c0e47098a5b665e2a126797',
          # 'partner_id' => 'top-sdk-java-20150211',
          'Version' => '2014-06-18',
          'Timestamp' => gmtdate,
          'SignatureMethod' => 'HMAC-SHA1',
          'SignatureVersion' => '1.0',
          'SignatureNonce' => UUIDTools::UUID.random_create.to_s,
          'Format' => 'json'
      }.merge(options)
      sorted_keys = paramaters.keys.sort

      # //生成stringToSign字符
      string_to_sign = "#{@HTTP_METHOD}#{@SEPARATOR}#{percent_encode('/')}#{@SEPARATOR}"

      canonicalized_query_string = ''
      sorted_keys.each do |key|
        value = paramaters[key]
        canonicalized_query_string.concat "#{@SEPARATOR}#{percent_encode(key).to_s()}#{@EQUAL}#{percent_encode(value)}"
      end
      string_to_sign.concat percent_encode(canonicalized_query_string[1..-1])

      h_mac_key = @aliyun_access_key + @SEPARATOR
      digest = OpenSSL::Digest.new('sha1')
      h = OpenSSL::HMAC.digest(digest, h_mac_key, string_to_sign)
      h = Base64.encode64(h).strip()

      paramaters['Signature'] = h
      query = ''
      paramaters.each do |k, v|
        query.concat "#{@SEPARATOR}#{percent_encode(k)}#{@EQUAL}#{percent_encode(v)}"
      end
      query = query[1..-1]
      "http://#{@host}/?#{query}"
    end

    def gmtdate
      Time.now.utc.iso8601
    end

    def percent_encode(var)
      begin
        CGI.escape(var).sub('+', '%20').sub('%7E', '~')
      rescue Exception => e
        puts e
      end
    end

    require 'rest-client'

    def execute(url, file = nil)
      host, query = url.split('?')
      begin
        res = RestClient.post host, query
      rescue Exception => e
        puts e.response
        raise e
      end
      puts res
      res.to_s
    end
  end

  module MetaInfo
    def submit_meta_info_job(bucket, object, location = 'oss-cn-hangzhou', user_data = '')
      params = {'Action' => 'SubmitMetaInfoJob',
                'Input' => {
                    'Bucket' => bucket,
                    'Location' => location,
                    'Object' => object}.to_json,
                'UserData' => user_data
      }.select { |k, v| v.present? }
      url = generate_url(params)
      res = JSON.parse execute(url)
      return res['RequestId'], AliyunMetaInfoJob.new(res['MetaInfoJob'])
    end

    def query_meta_info_list_job(job_ids)
      params = {'Action' => 'QueryMetaInfoJobList',
                'JobIds' => job_ids.join(',')
      }
      url = generate_url(params)
      res = JSON.parse execute(url)
      non_exist_job_ids = []
      non_exist_job_ids = res['NonExistJobIds']['String'] if res['NonExistJobIds'].present?
      return res['RequestId'], res['MetaInfoJobList']['MetaInfoJob'].map{|job|AliyunMetaInfoJob.new job}, non_exist_job_ids
    end
  end

  module AnalysisJob
    def submit_analysis_job

    end

    def query_analysis_job_list

    end
  end

  module Job
    def submit_job(bucket, object, output_object, template_id, pipeline_id,
                   location = 'oss-cn-hangzhou', output_bucket = nil, output_location = 'oss-cn-hangzhou', user_data = '')
      output_bucket = bucket if output_bucket.blank?
      params = {'Action' => 'SubmitJobs',
                'Input' => {
                    'Bucket' => bucket,
                    'Location' => location,
                    'Object' => object}.to_json,
                'OutputBucket' => output_bucket,
                'OutputLocation' => output_location,
                'Outputs' => [{
                                  'OutputObject' => output_object,
                                  'TemplateId' => template_id,
                                  'WaterMarks' => [],
                                  # "WaterMarks" => [{
                                  #                      "InputFile" => {
                                  #                          "Bucket" => "example-bucket",
                                  #                          "Location" => "oss-cn-hangzhou",
                                  #                          "Object" => "example-logo.png"},
                                  #                      "WaterMarkTemplateId" => "88c6ca184c0e47098a5b665e2a126797"}],
                                  'UserData' => user_data
                              }].to_json,
                'PipelineId' => pipeline_id
      }.select { |k, v| v.present? }
      url = generate_url(params)
      res = JSON.parse execute(url)
      return res['RequestId'], AliyunJobResult.new(res['JobResultList']['JobResult'].first)
    end

    def cancel_job

    end

    def query_job_list(job_ids)
      params = {'Action' => 'QueryJobList',
                'JobIds' => job_ids.join(',')
      }
      url = generate_url(params)
      res = JSON.parse execute(url)
      non_exist_job_ids = []
      non_exist_job_ids = res['NonExistJobIds']['String'] if res['NonExistJobIds'].present?
      return res['RequestId'], res['JobList']['Job'].map{|job|AliyunJob.new job}, non_exist_job_ids
    end

    def search_job

    end

    def query_job_list_by_pid

    end
  end

  module Snapshot
    def submit_snapshot_job

    end

    def query_snapshot_job_list

    end
  end

  module Pipeline
    def search_pipeline

    end

    def query_pipeline_list

    end

    def update_pipeline

    end
  end

  module Template
    def add_template(transcoding)
      params = {
        'Action' => 'AddTemplate',
        'Name' => transcoding.name,
        'Container' => {"Format": transcoding.container}.to_json,
        'Audio' => {
          "Codec":  transcoding.audio_codec,
          "Samplerate": transcoding.audio_samplerate,
          "Bitrate": transcoding.audio_bitrate,
          "Channels": transcoding.audio_channels
          }.to_json,
        'Video' => {
          "Codec": transcoding.video_codec,
          "Profile": transcoding.video_profile,
          "Bitrate": transcoding.video_bitrate,
          "Crf": transcoding.video_crf,
          "Width": transcoding.width,
          "Height": transcoding.height,
          "Fps": transcoding.video_fps,
          "Gop": transcoding.video_gop,
          "Preset": transcoding.video_preset,
          "ScanMode": transcoding.video_scanmode,
          "Bufsize": transcoding.video_bufsize,
          "Maxrate": transcoding.video_maxrate,
          'BitrateBnd' => {"Max": transcoding.video_bitrate_bnd_max, "Min": transcoding.video_bitrate_bnd_min}
          }.to_json,
        'state' => transcoding.state
      }.select { |k, v| v.present? }
      url = generate_url(params)
      res = JSON.parse execute(url)
      return res['RequestId'], AliyunTemplate.new(res['Template'])

    end

    def search_template

    end

    def query_template_list

    end

    def delete_template(transcoding)
      params = {
        'Action' => 'DeleteTemplate',
        'TemplateId' => transcoding.aliyun_template_id,
      }.select { |k, v| v.present? }
      url = generate_url(params)
      res = JSON.parse execute(url)
      return res['RequestId'], res['TemplateId']
    end

    def update_template

    end
  end

  module WaterMark
    def add_water_mark_template

    end

    def search_water_mark_template

    end

    def query_water_mark_template_list

    end

    def delete_water_mark_template

    end

    def update_water_mark_template

    end
  end

  class AliyunMetaInfoJob
    attr_accessor :job_id, :input, :state, :code, :message, :properties, :user_data, :creation_time

    def initialize(var)
      if var.is_a? Hash
        @job_id = var['JobId']
        @input = AliyunOSSFile.new var['Input']
        @state = var['State']
        @code = var['Code']
        @message = var['Message']
        @properties = AliyunProperties.new var['AliyunProperties']
        @user_data = var['UserData']
        @creation_time = var['CreationTime']
      end
    end
  end
  class AliyunOSSFile
    attr_accessor :bucket, :location, :object

    def initialize(var)
      if var.is_a? Hash
        @bucket = var['Bucket']
        @location = var['Location']
        @object = var['Object']
      end
    end
  end
  class AliyunProperties
    attr_accessor :width, :height, :bitrate, :duration, :fps, :file_size, :file_format

    def initialize(var)
      if var.is_a? Hash
        @width = var['Width']
        @height = var['Height']
        @bitrate = var['Bitrate']
        @duration = var['Duration']
        @fps = var['Fps']
        @file_size = var['FileSize']
        @file_format = var['FileFormat']
      end
    end
  end
  class AliyunJobResult
    attr_accessor :success, :code, :message, :job

    def initialize(var)
      if var.is_a? Hash
        @success = var['Success']
        @code = var['Code']
        @message = var['Message']
        @job = AliyunJob.new var['Job']
      end
    end
  end
  class AliyunJob
    attr_accessor :job_id, :input, :output, :state, :code, :message, :percent, :user_data, :pipeline_id, :creation_time

    def initialize(var)
      if var.is_a? Hash
        @job_id = var['JobId']
        @input = AliyunOSSFile.new var['Input']
        @output = AliyunOutput.new var['Output']
        @state = var['State']
        @code = var['Code']
        @message = var['Message']
        @percent = var['Percent']
        @user_data = var['UserData']
        @pipeline_id = var['PipelineId']
        @creation_time = var['CreationTime']
      end
    end
  end
  class AliyunOutput
    attr_accessor :output_file, :template_id, :water_mark_list, :properties, :user_data

    def initialize(var)
      if var.is_a? Hash
        @output_file = var['OutputFile']
        @template_id = var['TemplateId']
        @water_mark_list = var['WaterMarkList'].map{|wm|AliyunWaterMark.new wm} if var['WaterMarkList'].present?
        @properties = var['Properties']
        @user_data = var['UserData']
      end
    end
  end
  class AliyunWaterMark
    attr_accessor :input_file, :water_mark_template_id

    def initialize(var)
      if var.is_a? Hash
        @input_file = AliyunOSSFile.new var['InputFile']
        @water_mark_template_id = var['WaterMarkTemplateId']
      end
    end
  end

  class AliyunViedo
    attr_accessor :codec, :profile, :bitrate, :crf , :width, :height, :fps, :gop, :preset, :scanmode, :bufsize, :maxrate, :bitratebnd
    def initialize(var)
      if var.is_a? Hash
        @codec = var['Codec']
        @profile = var['Profile']
        @bitrate = var['Bitrate']
        @crf = var['Crf']
        @width = var['Width']
        @height = var['Height']
        @fps = var['Fps']
        @gop = var['Gop']
        @preset = var['Preset']
        @scanmode = var['ScanMode']
        @bufsize = var['Bufsize']
        @maxrate = var['Maxrate']
        @bitratebnd = AliyunBitrateBnd.new var['BitrateBnd']
      end
    end
  end

  class AliyunBitrateBnd
    attr_accessor :max, :min
    def initialize(var)
      if var.is_a? Hash
        @max = var['Max']
        @min = var['Min']
      end
    end
  end

  class AliyunAudio
    attr_accessor :codec, :samplerate, :bitrate, :channels 

    def initialize(var)
      if var.is_a? Hash
        @codec = var['Codec']
        @samplerate = var['Samplerate']
        @bitrate = var['Bitrate']
        @channels = var['Channels']
      end
    end
  end

  class AliyunTemplate
    attr_accessor :id, :name, :container, :audio, :video, :state  

    def initialize(var)
      if var.is_a? Hash
        @id = var['Id']
        @name = var['Name']
        @container = AliyunContainer.new var['Container']
        @audio = AliyunContainer.new var['Audio']
        @video = AliyunContainer.new var['Video']
        @state = var['State']
      end
    end
  end

  class AliyunContainer
    attr_accessor :format

    def initialize(var)
      if var.is_a? Hash
        @format = var['Format']
      end
    end
  end



  module Status
    SUBMITTED = 'Submitted'
    TRANSCODING = 'Transcoding'
    TRANSCODE_SUCCESS = 'TranscodeSuccess'
    TRANSCODE_FAIL = 'TranscodeFail'
    TRANSCODE_CANCELLED = 'TranscodeCancelled'
    ANALYZING = 'Analyzing'
    SUCCESS = 'Success'
    FAIL = 'Fail'
  end

end
