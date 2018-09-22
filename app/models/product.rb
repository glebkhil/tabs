class Product < Sequel::Model(:product)

  def self.available
    Product.distinct
  end

  def self.available_by_bot(bot)
    begin
      Product.select(:price__id, :product__russian, :product__icon, Sequel.as(:product__id, :prod)).join(:price, price__product: :product__id).where(price__bot: bot.id).distinct(:product__id)
    rescue
      nil
    end
  end

  def self.wholesale_by_bot(bot)
    Product.select(:price__id, :product__russian, :product__icon, Sequel.as(:product__id, :prod)).join(:price, price__product: :product__id).where(price__bot: bot.id).where('price > ?', 3350).distinct(:product__id)
  end


  def make_line(city, dist)
    "#{icon(self[:icon], self.id.to_s)} #{self.russian} #{city} #{dist}"
  end

  def self.by_city(city)
    c = City.find(latin: city)
    its = c.items
    Product.distinct.filter(items: its)
  end

  def self.sellers_by_product(product)
    Client.
      distinct(:item__id).
      join(:item, item__client: :client__id).
      where(item__product: product.id)
  end

  def to_str
    "#{icon(self[:icon])} #{self.russian}"
  end

  def cents2uah(cents)
    ((cents.to_f/100) * UAH_RATE).round
  end

  def max_price(bot)
    Price.select(:price__price, :price__qnt).find(product: self.id, bot: bot.id)
  end

  def prices(bot)
    prc = {}
    Price.where(product: self.id, bot: bot.id).each do |pr|
      prc.merge!({pr.qnt => bot.amo_pure(pr.price)})
    end
    prc.empty? ? '' : prc.to_yaml
  end

  def prices_hash(bot)
    prc = {}
    Price.where(product: self.id, bot: bot.id).each do |pr|
      prc.merge!(pr.id => {pr.qnt => pr.price})
    end
    prc.empty? ? {} : prc
  end

  def price_string(bot, qnt)
    s = Price.find(product: self.id, qnt: qnt,  bot: bot.id)
    if !s.nil?
      "#{s.qnt} за #{cents2uah(s.price)}грн."
    else
      false
    end
  end

end