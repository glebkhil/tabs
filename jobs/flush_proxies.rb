require_relative './requires'
logger = CronLogger.new
logger.noise "Flushing proxies ... "
Prox.flush
DB.disconnect
logger.noise "Finished."