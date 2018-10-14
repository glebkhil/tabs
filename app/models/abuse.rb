class Dispute < Sequel::Model(:dispute)

  SOLVED = 1
  REJECTED = 2
  NEW = 0

  def approve(bot, answ, oper)
    t = Trade[self.trade]
    i = Item[t.item]
    buyer = Client[t.buyer]
    Client::__refunds.cashin(i.price, bot.beneficiary, Meth::__cash, oper)
    buyer.cashin(i.price, bot.beneficiary, Meth::__cash, oper)
    self.answer = answ
    self.closed = Time.now
    self.status = Dispute::SOLVED
    self.save
  end

  def reject(answ, oper)
    self.answer = answ
    self.operator = oper.id
    self.status = Dispute::SOLVED
    # self.closed = Time.now
    self.save
  end

end