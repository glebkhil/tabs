require_relative './requires'
logger = CronLogger.new

BCHANGE = BestchangeRates.new
rats = BestchangeRates.new.rates('Exmo USD' => 'Visa/MasterCard UAH').first[:get].to_f.round(2)
puts "Today WEX exchange rate: #{rats}"

logger.noise "Setting sales ... "

sls = Vars.where('today_sales is not null and today_sales > 0').order(Sequel.desc(:today_sales))
max_sales = sls.first
min_sales = sls.last
apteka = rand(min_sales.today_sales.to_i..max_sales.today_sales.to_i)
logger._say "Max sales today ... "
logger.answer "#{max_sales.today_sales}", :green
logger._say'APTEKA TODAY SALES: '
logger.answer "#{apteka}", :green
bots = Bot.all
bots.each do |c|
  begin
    today_cnt = c.today_bot_sales(Date.today)
    cnt = c.sales
    logger.noise "Today_sales=#{today_cnt}, sales=#{cnt} for #{c.tele}"
    c.set_var('sales', c.sales)
    c.set_var('sales', 4000) if c.id == 574
    c.set_var('sales', 4300) if c.id == 598
    c.set_var('sales', 5200) if c.id == 542
    c.set_var('sales', 6000) if c.id == 605
    c.set_var('sales', 2200) if c.id == 600
    c.set_var('today_sales', today_cnt)
    c.set_var('today_sales', apteka) if c.id == 598
    c.set_var('EXMO_UAH', rats.to_s)
  rescue => ex
    logger.noise ex.message
    logger.noise "Sales count not set"
  end
end
DB.disconnect
logger.noise "Finished."