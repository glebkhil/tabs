require 'rubygems'
require 'openssl'
require 'tor/hidden-service'

class DarksideHidden < Tor::HiddenService
  attr_accessor :service

  def self.start
    @service = Tor::HiddenService.new(
      server_port: ENV['PORT'] || 5000,
      temp_dir: "/code/theautobot/tmp",
      private_key: OpenSSL::PKey::RSA.generate(1024).to_pem.to_s,
    )
    @service.start
    return @tor_pid
  end

  def stop(pid)
    Process.kill :SIGTERM, pid
  end

  def generate

  end

end

hid = DarksideHidden.start
res = ''
while (!res.include?('dark'))
  hid.generate
  onion = @service.hostname
  puts "Trying #{onion} ... "
  DarksideHidden.stop(hid)
end
puts "Onion URL: #{res}"