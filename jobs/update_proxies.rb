require_relative './requires'
logger = CronLogger.new

logger.noise "Updating proxies ... "
proxies = "181.215.12.172:3954:user12772:79xb0c
181.215.26.47:3954:user12772:79xb0c
191.96.17.227:3954:user12772:79xb0c
181.214.0.124:3954:user12772:79xb0c
181.215.12.153:3954:user12772:79xb0c
".split("\n")

proxies.each do |proxy_string|

  proxy = proxy_string.split(":")
  Prox.create(host: proxy[0], port: proxy[1], status: Prox::ONLINE, login: 'user12772', password: '79xb0c', provider: "proxio")
  logger.say("Proxy #{proxy.first}:#{proxy.last} added to proxy pool")
end

Prox::flush
DB.disconnect
logger.noise "Finished."