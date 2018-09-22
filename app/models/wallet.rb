class Wallet < Sequel::Model(:wallet)
  ACTIVE = 1
  INACTIVE = 0

  def self.system
    Wallet.find(bot: Bot::chief.id, meth: Meth::__bitcoin.id, client: Client::root.id)
  end
end