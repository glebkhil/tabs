class Plugin < Sequel::Model(:plugin)
  ACTIVE = 1
  INACTIVE = 0

  def conf(key)
    params = JSON.parse(self.config)
    params[key] || 'unknown'
  end

  def readable_status
    case self.status
      when Plugin::ACTIVE
        "активен"
      when Plugin::INACTIVE
        "неактивен"
    end
  end

  def active_list(bot)
    Plugin.join(:game, :game__plugin => :plugin__id).where(bot: bot.id)
  end

end