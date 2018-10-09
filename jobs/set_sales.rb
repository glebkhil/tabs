require_relative './requires'
logger = CronLogger.new

BCHANGE = BestchangeRates.new
rats = BestchangeRates.new.rates('Exmo USD' => 'Visa/MasterCard UAH').first[:get].to_f.round(2)
puts "Today WEX exchange rate: #{rats}"

logger.noise "Setting sales ... "
bots = Bot.all
bots.each do |c|
  begin
    today_cnt = c.today_bot_sales(Date.today)
    cnt = c.sales
    logger.noise "Today_sales=#{today_cnt}, sales=#{cnt} for #{c.tele}"
    c.set_var('sales', c.sales)
    c.set_var('sales', 4000) if c.id == 574
    c.set_var('sales', 4300) if c.id == 598
    c.set_var('sales', 4200) if c.id == 542
    c.set_var('sales', 6000) if c.id == 605
    c.set_var('sales', 700) if c.id == 600
    c.set_var('today_sales', today_cnt)
    c.set_var('EXMO_UAH', rats.to_s)
  rescue => ex
    logger.noise ex.message
    logger.noise "Sales count not set"
  end
end
DB.disconnect
logger.noise "Finished."