require_relative './requires'
logger = CronLogger.new

logger.noise "Updating proxies ... "
proxies = "191.101.104.67:7389
191.101.126.219:7389
191.101.104.89:7389
191.101.126.170:7389
191.101.126.195:7389
".split("\n")

# proxies.each do |proxy_string|
#   puts proxy_string
#   proxy = proxy_string.split(":")
#   auth = proxy_string.split(" ").last.split(":")
#   Prox.create(host: proxy[0], port: proxy[1], status: Prox::ONLINE, login: 'user12772', password: '79xb0c', provider: "proxio")
#   logger.say("Proxy #{proxy.first}:#{proxy.last} added to proxy pool")
# end

Prox.flush
DB.disconnect
logger.noise "Finished."