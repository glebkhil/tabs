require_relative './requires'
logger = CronLogger.new

logger.noise "Updating proxies from file ... "
proxies = "185.233.201.118:9253:rHnDkq:nXwktv
185.233.203.152:9114:rHnDkq:nXwktv
185.233.200.65:9598:rHnDkq:nXwktv
185.233.202.69:9511:rHnDkq:nXwktv
185.233.200.182:9457:rHnDkq:nXwktv
185.233.200.50:9476:rHnDkq:nXwktv
185.233.203.60:9196:rHnDkq:nXwktv
185.233.203.114:9925:rHnDkq:nXwktv
185.233.203.249:9814:rHnDkq:nXwktv
185.233.203.41:9321:rHnDkq:nXwktv
138.59.204.213:9161:abFbnM:dUNf7F
138.59.204.212:9037:abFbnM:dUNf7F
138.59.204.211:9245:abFbnM:dUNf7F
138.59.204.210:9156:abFbnM:dUNf7F
138.59.204.209:9240:abFbnM:dUNf7F
138.59.204.208:9769:abFbnM:dUNf7F
138.59.204.207:9051:abFbnM:dUNf7F
138.59.204.206:9260:abFbnM:dUNf7F
138.59.204.205:9175:abFbnM:dUNf7F
138.59.204.204:9741:abFbnM:dUNf7F
138.59.204.203:9656:abFbnM:dUNf7F
138.59.204.202:9123:abFbnM:dUNf7F
138.59.204.201:9315:abFbnM:dUNf7F
138.59.204.200:9532:abFbnM:dUNf7F
138.59.204.199:9661:abFbnM:dUNf7F
138.59.204.198:9875:abFbnM:dUNf7F
138.59.204.197:9593:abFbnM:dUNf7F
138.59.204.196:9516:abFbnM:dUNf7F
138.59.204.195:9150:abFbnM:dUNf7F
138.59.204.17:9978:abFbnM:dUNf7F
104.227.96.175:9337:H3w0E4:eedoL6
104.227.102.204:9925:H3w0E4:eedoL6
104.227.102.15:9756:H3w0E4:eedoL6
107.152.153.72:9324:H3w0E4:eedoL6
104.227.102.108:9445:H3w0E4:eedoL6
104.227.96.100:9170:H3w0E4:eedoL6
104.227.96.142:9405:H3w0E4:eedoL6
138.128.19.180:9672:H3w0E4:eedoL6
104.227.102.58:9006:H3w0E4:eedoL6
138.128.19.49:9270:H3w0E4:eedoL6
107.152.153.102:9766:n0cGkH:CWgzhK
138.128.19.171:9746:n0cGkH:CWgzhK
104.227.96.75:9871:n0cGkH:CWgzhK
".split("\n")

proxies.each do |proxy_string|
  proxy = proxy_string.split(":")
  Prox.create(host: proxy[0], port: proxy[1], status: Prox::ONLINE, login: proxy[2], password: proxy[3], provider: "proxy6")
  logger.say("Proxy #{proxy.first}:#{proxy.last} added to proxy pool")
end

Prox::flush
DB.disconnect
logger.noise "Finished."