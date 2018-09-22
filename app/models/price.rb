class Price < Sequel::Model(:price)

  def self.cents2uah(cents)
    ((cents.to_f/100) * UAH_RATE).round
  end

  def to_str
    "#{self.qnt} за #{Price::cents2uah(self.price)}грн."
  end

end