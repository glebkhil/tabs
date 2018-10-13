class Gameplay < Sequel::Model(:game)
  ACTIVE = 1
  INACTIVE = 0

  def available_numbers
    rng = eval("#{self.conf('range')}")
    nums = []
    b = Bot[self.bot]
    Bet.where(game: self.id).each do |num|
      nums.push(num.number)
    end
    puts rng.inspect
    puts nums.inspect
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