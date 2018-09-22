require "net/http"
require "uri"
require 'openssl'
require "base64"
require "rubygems"
require "json"

module Livecoin

  def self.redeem(code, api_key, secret_key)
    uri = URI::parse("https://api.livecoin.net/payment/voucher/redeem")

    data = {
        'voucher_code'=> code
    }

    sorted_data = data.sort_by { |key, value| key }

    sha256 = OpenSSL::Digest::SHA256.new
    signature = OpenSSL::HMAC.hexdigest(sha256, secret_key, URI.encode_www_form(sorted_data)).upcase

    request = Net::HTTP::Post.new(uri)
    request.set_form_data(sorted_data)
    request.add_field("Api-key", api_key)
    request.add_field("Sign", signature)

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl:uri.scheme == 'https') {|http|
      http.request(request)
    }

    response_data = JSON.parse(response.body())

    return response_data
  end

end
