class Ledger < Sequel::Model(:ledger)

  ACTIVE = 1
  INACTIVE = 0
  CLEARED = 2

  def cleared?
    self.status == Ledger::CLEARED
  end

end