module MTSUtils
  def self.included(base)
    base.send(:include, Core)
    base.send(:include, Utils)
  end

  module Core
    require 'uuidtools'
    # TODO config
    @host = 'mts.aliyuncs.com'
    @aliyun_access_id = '1cnDtYk8fMS0lyoM'
    @aliyun_access_key = 'PR6H6WIq4gqun4BJ5bwWQQt5BUO5su'
    @SEPARATOR = '&'
    @EQUAL = '='
    @HTTP_METHOD = 'POST'

    def generate_url(options = {})
      paramaters = {
          'AccessKeyId' => @aliyun_access_id,
          'Action' => 'QueryMediaList',
          'MediaIds' => '88c6ca184c0e47098a5b665e2a126797',
          'partner_id' => 'top-sdk-java-20150211',
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
      # URI.encode(var)
      CGI.escape(var).sub('+', '%20').sub('%7E', '~')
    end
  end

  module Utils

  end
end
