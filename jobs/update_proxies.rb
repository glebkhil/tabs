require_relative './requires'
logger = CronLogger.new

logger.noise "Updating proxies ... "
proxies = "178.32.67.218:5964
213.32.84.209:5964
147.135.175.251:5964
193.70.97.29:5964
213.32.84.204:5964
178.32.67.214:5964
213.32.84.226:5964
178.32.67.152:5964
147.135.175.226:5964
178.32.67.164:5964
".split("\n")

# proxies.each do |proxy_string|
#   proxy = proxy_string.split(":")
#   auth = proxy_string.split(" ").last.split(":")
#   Prox.create(host: proxy[0], port: proxy[1], status: Prox::ONLINE, login: 'user12772', password: '79xb0c', provider: "proxio")
#   logger.say("Proxy #{proxy.first}:#{proxy.last} added to proxy pool")
# end

DB.disconnect
logger.noise "Finished."