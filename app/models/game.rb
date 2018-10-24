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

  def question?
    return false if self.conf('question').to_s == "false"
    return true
  end

  def can_post?(client)
    case self.title
      when 'lottery'
        if Bet.find(client: client.id, game: self.id).nil?
          return true
        elsif !self.available_numbers.nil? or self.available_numbers.count > 0
          return false
        end
      when 'voting'
        if Vote.find(username: client.username, bot: client.bot).nil?
          return true
        end
      when 'referals'
        return true
      when 'announcement'
        return true
      when 'question'
        client.has_answer?(self) ? true : false
    end
  end

  def available_numbers
    rng = eval("#{self.conf('range')}")
    puts rng.inspect
    Bet.where(game: self.id).each do |num|
      [rng] - [num.number]
    end
    rng
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