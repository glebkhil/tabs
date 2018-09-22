require_relative './requires'
l = CronLogger.new

l.say "Addingg proxis ... "
list = File.open('./proxylist.txt').read.split("\n")
list.each do |proxy|
  web = Mechanize.new
  host = proxy.split(':').first
  port = proxy.split(':').last
  begin
    l._say "Checking #{host}:#{port} ... "
    p = Prox.find_or_create(host: host, port: port)
    web.keep_alive = false
    web.agent.set_socks(host, port)
    web.agent.open_timeout = 1
    ip = web.get('http://ipecho.net/plain').body
    p.status = Prox::ONLINE
    l.answer("online (#{ip})", :green)
  rescue => e
    p.status = Prox::OFFLINE
    l.answer(e.message, :green)
  end
  p.save
  web.shutdown
end