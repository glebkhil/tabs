module Btce
  class API
    BTCE_DOMAIN = "wex.nz"
  end
end

module Btce
  class API

    class << self
      def get_https(opts={})
        raise ArgumentError if not opts[:url].is_a? String
        uri = URI.parse opts[:url]
        # proxy = Prox.get_active
        http = Net::HTTP.new(
            uri.host,
            uri.port
            # proxy.host,
            # proxy.port,
            # 'service_4395',
            # '72953e5865'
        )
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        if opts[:params].nil?
          request = Net::HTTP::Get.new uri.request_uri
        else
          request = Net::HTTP::Post.new uri.request_uri
          request.add_field "Key", opts[:key]
          request.add_field "Sign", opts[:signed]
          request.set_form_data opts[:params]
        end
        response = http.request request
        response.body
      end
    end
  end
end