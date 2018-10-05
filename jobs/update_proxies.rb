require_relative './requires'
logger = CronLogger.new

logger.noise "Updating proxies ... "
proxies = "185.161.210.125:4620
185.161.210.253:4620
193.111.153.176:4620
".split("\n")

proxies.each do |proxy_string|
  proxy = proxy_string.split(":")
  Prox.create(host: proxy[0], port: proxy[1], status: Prox::ONLINE, login: 'user12772', password: '79xb0c', provider: "proxio")
  logger.say("Proxy #{proxy.first}:#{proxy.last} added to proxy pool")
end

Prox::flush
DB.disconnect
logger.noise "Finished."