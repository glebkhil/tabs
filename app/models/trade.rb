class Trade < Sequel::Model(:trade)
  include TSX::Helpers

  PENDING = 0
  TRADING = 1
  FINALIZED = 2
  DISPUTED = 3
  FINISHED = 4
  ESCROW = 5
  ESCROW_PENDING = 6

  ESCROW_SALE = 1
  ESCROW_JOB = 2
  ESCROW_SERVICE = 3

  def escrowed?
    self.escrow > 0
  end

  def confirmation_buttons(client, method)
    it = Item[self.item]
    balance = client.available_cash
    price = self.amount + self.commission
    if balance >= it.discount_price
      balance_btn = true
    else
      balance_btn = false
    end
    if client.is_admin?(Bot[client.bot])
      take_free_btn = true
    else
      take_free_btn = false
    end
    {balance_btn: balance_btn, take_free_btn: take_free_btn, links: true, method: method}
  end

  def self.expired_trades
    Trade.where(Sequel.lit("status = ? and created < ?", Trade::PENDING, Time.now - RESERVE_INTERVAL.minute))
  end

  def pending?
    self.status == Trade::PENDING
  end

  def disputed?
    self.status == Trade::DISPUTED
  end

  def trading?
    self.status == Trade::TRADING
  end

  def finalized?
    self.status == Trade::FINALIZED
  end

  def finished?
    self.status == Trade::FINISHED
  end

  def mine?
    self.owner == self.id
  end

  def readable_status
    t("trades.#{self.status}")
  end

  def define_method
    got_trade = Ledger.where(trade: self.id).exclude(meth: nil).order(Sequel.desc(:meth)).limit(1)
    if got_trade.first.nil?
      Meth.__cash
    else
      Meth[got_trade.meth]
    end
  end

  def finalize(b, code, meth, client)
    codes = (self.code || '') << ", " << code
    self.status = Trade::FINALIZED
    self.code = codes
    self.meth = meth.id
    self.closed = Time.now
    self.save
    it = Item[b.id]
    am = it.discount_price
    pri = Price.find(id: it.prc)
    it.status = Item::SOLD
    it.sold = Time.now
    it.price = am
    it.qnt = pri.qnt
    it.unlock = nil
    it.save
    client.pay_for_trade(self)
  end

end