require_relative './requires'
logger = CronLogger.new

BCHANGE = BestchangeRates.new
rats = BestchangeRates.new.rates('Exmo USD' => 'Visa/MasterCard UAH').first[:get].to_f.round(2)
puts "Today WEX exchange rate: #{rats}"

logger.noise "Setting sales ... "

sls = Vars.where('today_sales is not null and today_sales > 0').order(Sequel.desc(:today_sales))
# bots = Bot.all
sls.each do |sl|
  c = Bot[sl[:bot]]
  begin
    today_cnt = c.today_bot_sales(Date.today - 1.day)
    Gameplay.create(title: 'referals', bot: c.id, status: Gameplay::ACTIVE, config: '{   "interest": "5",   "counter": "0",   "job": "daily",   "question":  "false" }')
    cnt = c.sales
    logger.noise "Today_sales=#{today_cnt}, sales=#{cnt} for #{c.tele}"
    c.set_var('sales', c.sales)
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