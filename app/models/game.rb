class Gameplay < Sequel::Model(:game)
  include TSX::Helpers

  ACTIVE = 1
  INACTIVE = 0
  GAMEOVER = 3

  JOB = 0
  VIEW = 1

  @progress = 0
  @maximum = 0

  def start
    self.title
  end

  def available_numbers
    rng = eval("#{self.conf('range')}")
    puts rng.inspect
    Bet.where(game: self.id).each do |num|
      [rng] - [num.number]
    end
    rng
  end

  def self.fetchGame(bot)
    return nil if Gameplay.where(status: Gameplay::ACTIVE, bot: bot.id).count == 0
    found = Gameplay.where(status: Gameplay::ACTIVE, bot: bot.id).order(Sequel.asc(:last_run)).first
    found.update(last_run: Time.now)
    found
  end

  def readable_status
    case self.status
      when Gameplay::ACTIVE
        "активен"
      when Gameplay::INACTIVE
        "неактивен"
      when Gameplay::GAMEOVER
        "завершена"
    end
  end

  def inc
    cur = self.conf('counter')
    self.sconf('counter', (cur.to_i + 1).to_s)
  end

  def conf(key)
    params = JSON.parse(self.config)
    params[key] || 0
  end

  def sconf(key, value)
    params = JSON.parse(self.config)
    params[key] = value
    self.config = JSON.dump(params)
    self.save
  end

end