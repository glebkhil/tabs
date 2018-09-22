class Escrow < Sequel::Model(:escrow)
  include TSX::Helpers

  PENDING = 0
  TRADING = 1
  FINALIZED = 2
  DISPUTED = 3
  FINISHED = 4
  REJECTED = 5
  PAUSED = 6

  def readable_status(client)
    if self.buyer == client.id
      t("escrow.buyer.#{self.status}")
    else
      t("escrow.seller.#{self.status}")
    end
  end

  def chat
    Chat::find_or_create(
      escrow: self.id
    )
  end

  def say(from, to, message)
    Message.create(
        from: from.id,
        to: to.id,
        message: message
    )
  end

  def can_dispute?
    self.expires < Time.now
  end

end