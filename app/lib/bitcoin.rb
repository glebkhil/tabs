require 'logger'
require 'net/http'

module Telebot
  module Bitcoin

    class << self
      attr_accessor :config
    end

    def self.config
      @config ||= Config.new
    end

    def self.configure
      yield(config)
    end

    class Config
      attr_accessor :uri
      attr_accessor :logger
      attr_accessor :level
    end

    class Error < Exception
    end

    class Response

      def initialize code, message
        @code = code
        @message = message
      end
    end


    class Command

      attr_accessor :code
      attr_accessor :message
      attr_accessor :json

      def initialize cmd, *args
        self.run cmd, *args
      end

      def to_s
        Bitcoin.config.logger.warn "RESPONSE: #{self.code}: #{self.message}"
      end

      def run(command, *args)
        cmds = {method: command, params: args, id: 'jsonrpc'}
        Bitcoin.config.logger.info "running #{cmds}"
        post_body = Oj.dump(cmds, kind: :compat)
        cmd_j = cmds.to_json
        puts "POST:: " + post_body.to_s
        puts "CMDS:: " + cmds.to_s
        @uri = URI.parse(Bitcoin.config.uri)
        http    = Net::HTTP.new(@uri.host, @uri.port)
        request = Net::HTTP::Post.new(@uri.request_uri)
        request.basic_auth @uri.user, @uri.password
        request.content_type = 'application/json'
        request.body = cmd_j
        raw_response = http.request(request).body
        puts raw_response.to_s
        hash = JSON.parse(raw_response)
        Bitcoin.config.logger.info "hash result = #{hash['result']}"
        Bitcoin.config.logger.info "hash error = #{hash['error']}"
        if hash['error']
          self.code = hash['error']['code']
          self.message =hash['error']['message']
        else
          self.json = hash['result'].to_json
          self.code = true
          self.message =hash['result']
        end
        Bitcoin.config.logger.warn "#{self.to_s}"
        self
      end
    end
  end

end