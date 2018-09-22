require 'net/https'
require "json"

module Webmoney

  class WM
    include Webmoney
  end

  def self.check_webmoney(code)
    cert = OpenSSL::X509::Certificate.new(File.read("webmoney.pem"))
    key = OpenSSL::PKey::RSA.new(File.read("webmoney.key"), "password")
    mywm = MyWM.new(wmid: '123456789012', cert: cert, key: key)
  end

end