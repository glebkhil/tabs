require_relative './requires'
l = CronLogger.new

l._say "Finalizing escrows ... "
ts = Escrow.where(status: Escrow::TRADING)
l.answer(ts.count, :green)
ts.each do |e|
  l._say "Finalizing escrow ##{e.id}... "
  e.status = Escrow::FINALIZED
  e.save
  seller = Client[e.seller]
  buyer = Client[e.buyer]
  comm = e.commission
  price = e.amount
  Client::__commission.cashin(comm, buyer, Meth::__cash, Client::__tsx, "Страховые комиссионные за сделку ##{e.id}")
  buyer.cashin(price, Client::__escrow, Meth::__cash, Client::__tsx, "Возврат застрахованных средств за сделку ##{e.id}")
  Client::__escrow.cashin(price, seller, Meth::__cash, Client::__tsx, "Возврат застрахованных средств за сделку ##{e.id}")
  seller.cashin(price, buyer, Meth::__cash, Client::__tsx, "Оплата сделки ##{e.id}")
  l.answer('finalized', :green)
end
DB.disconnect
puts "Finished."
