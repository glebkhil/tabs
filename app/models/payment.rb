class Payment < Sequel::Model(:payment)
  ACTIVE = 1
  INACTIVE = 2
end