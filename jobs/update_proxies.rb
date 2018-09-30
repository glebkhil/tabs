require_relative './requires'
logger = CronLogger.new

logger.noise "Updating proxies ... "
proxies = "5.188.32.189:9285
5.188.33.246:9285
5.188.33.98:9285
5.188.33.168:9285
5.188.33.217:9285
5.188.33.93:9285
5.188.32.249:9285
5.188.32.21:9285
5.188.33.85:9285
5.188.32.231:9285
".split("\n")

proxies.each do |proxy_string|
  proxy = proxy_string.split(":")
  Prox.create(host: proxy[0], port: proxy[1], status: Prox::ONLINE, login: 'user12772', password: '79xb0c', provider: "proxio")
  logger.say("Proxy #{proxy.first}:#{proxy.last} added to proxy pool")
end

Prox::flush
DB.disconnect
logger.noise "Finished."