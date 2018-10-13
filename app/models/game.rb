class Gameplay < Sequel::Model(:game)
  ACTIVE = 1
  INACTIVE = 0

  def readable_status
    case self.status
      when Gameplay::ACTIVE
        "активен"
      when Gameplay::INACTIVE
        "неактивен"
    end
  end

  def available_numbers
    rng = eval("#{self.conf('range')}")
    nums = []
    b = Bot[self.bot]
    Bet.where(game: self.id).each do |num|
      nums.push(num.number)
    end
    puts "NUMBERS LEFT".colorize(:yellow)
    puts (rng - nums).inspect
    rng - nums
  end

  def over!
    self.status = self::INACTIVE
    self.save
  end

  def conf(key)
    params = JSON.parse(self.config)
    params[key] || 'unknown'
  end

end