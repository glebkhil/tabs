stat.require_relative './requires'
l = CronLogger.new

l._say "Fixing item statuses ... "
items = Item.select(Sequel.as(:item__id, :itemid)).join_table(:left, :trade, :trade__item => :item__id).where('item.status = 3 and trade.id is NULL')
l.answer(items.count, :green)
items.each do |item|
  it = Item[item[:itemid]]
  l._say "Fixing item ##{item[:itemid]} ... "
  it.status = Item::ACTIVE
  it.save
  l.answer('fixed', :green)
end
DB.disconnect
puts "Finished."
