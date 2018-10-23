require_relative './requires'
logger = CronLogger.new

logger.noise "Calculating data for charts ... "
m_int = [*Date.today.at_beginning_of_month .. Date.today.at_end_of_month]
line = []
Bot.where(listed: 1).limit(1).each do |bot|
  bot.products.each do |prc|
    prod = Product[prc.product]
    line[prod.id] = {name: "#{prod.icon} #{prod.russian}", data: [[12, 345, 45, 34, 34,45, 4], [12, 345, 45, 34, 34,45, 4]]}
  end
  File.open("#{bot.id}-#{Date.today.month}-#{Date.today.year}.csv", 'w') { |file| file.write(line) }
end
DB.disconnect
logger.noise "Finished."