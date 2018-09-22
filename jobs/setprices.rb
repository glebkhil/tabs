require_relative './requires'
logger = CronLogger.new

logger.noise "Setting prices ... "
items = Item.where(prc: nil, bot: 17).order(Sequel.desc(:id))
items.each do |c|
  price = Price.find(qnt: c.qnt)
  if price.nil?
    logger.noise "Bot #{Bot[c.bot].tele} has no price for #{Product[c.product].russian}"
  else
    logger.noise "Bot #{Bot[c.bot].tele}  has price for #{c.qnt} #{Product[c.product].russian}. Now it is #{Bot[c.bot].amo(price.price)}"
    c.prc = price.id
    c.save
  end
end
DB.disconnect
logger.noise "Finished."