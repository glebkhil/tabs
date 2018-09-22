class Country < Sequel::Model(:country)
  include TSX::Helpers

  def self.available
    Country.distinct
  end

  def self.line(country)
    ctr = ISO3166::Country[Country[country[:id]].code]
    if !ctr.nil?
      line = ctr.emoji_flag  << " " << ctr.local_name
      line << " " << City.cities_line(country.cities)
    else
      "неизвестная страна"
    end
  end

  def self.UKRAINE
    Country.find(code: 'UA')
  end

  def self.RUSSIA
    Country.find(code: 'RU')
  end

  def to_str(bot)
    "#{icon(bot.icon_geo)} #{self[:russian]}"
  end

  def flag
    co = ISO3166::Country[self.code]
    co.emoji_flag << " " << co.local_name
  end
end