require_relative './requires'
logger = CronLogger.new

logger.noise "Deleting accounting ... "
clis = Client.all
clis.each do |t|
  cash = t.available_cash
  puts "Balance of #{t.username} is #{t.available_cash}"
  t.balance = cash
  t.save
end
