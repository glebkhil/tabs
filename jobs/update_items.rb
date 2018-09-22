require_relative './requires'
logger = CronLogger.new

items = Item.where(status: Item::ACTIVE).all
items.each do |it|
  puts "Aging item ##{it.id} .. "
  b = Bot[it.bot]
  gr = (Time.now - it.created).to_i/86400
  puts "  .. Item Lifetime: #{gr}"
  puts "  .. Discount term: #{b.discount_period}"
  if gr > b.discount_period
    it.update(:old => Item::OLD)
    puts " .. old item".colorize(:red)
  else
    it.update(:old => Item::FRESH)
    puts "  .. fresh".colorize(:green)
  end
end

DB.disconnect
logger.noise "Finished."