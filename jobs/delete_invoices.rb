require_relative './requires'
logger = CronLogger.new

logger.noise "Deleting invoices ... ok"
TSX::Invoice.where('used < ?', Date.today - 1.day).delete

DB.disconnect
logger.noise "Finished."