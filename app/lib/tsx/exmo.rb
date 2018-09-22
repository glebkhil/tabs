require 'net/https'
require "json"

module Exmo
  class Error < StandardError
    attr_reader :object

    def initialize(object)
      @object = object
    end
  end

  class API

    def initialize(params = {})
      @key = params[:key]
      @secret = params[:secret]
    end

    def api_query(method, params = nil)
      raise ArgumentError unless method.is_a?(String) || method.is_a?(Symbol)
      params = {} if params.nil?
      puts params.inspect
      params['nonce'] = nonce
      uri = URI.parse(['https://api.exmo.com/v1', method].join('/'))
      post_data = URI.encode_www_form(params)
      digest = OpenSSL::Digest.new('sha512')
      sign = OpenSSL::HMAC.hexdigest(digest, @secret, post_data)
      headers = {
          'Sign' => sign,
          'Key'  => @key
      }
      req = Net::HTTP::Post.new(uri.path, headers)
      req.body = post_data
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'
      response = http.request(req)
      unless response.code == '200'
        raise Exmo::Error.new(__method__), ['http error:', response.code].join(' ')
      end
      result = response.body.to_s
      unless result.is_a?(String) && valid_json?(result)
        raise Exmo::Error.new(__method__), "Invalid json"
      end
      JSON.load result
    end

    private

    def valid_json?(json)
      JSON.parse(json)
      true
    rescue
      false
    end

    def nonce
      Time.now.strftime("%s%6N")
    end
  end
end