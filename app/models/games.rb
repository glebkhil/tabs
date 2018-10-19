class Games
  attr_accessor :bot

  def initialize(bot)
    @bot = bot
  end

  def self.choose_one
    p = Gameplay.
      join(:plugin, :plugin__id => :game__plugin).
      where(:bot => @bot.id, :status => Gameplay::ACTIVE).
      exclude(:plugin__job => Gameplay::JOB).
      order(Sequel.desc(:game__last_run)).limit(1).first
    p.update(:last_run => Date.now)
    p
  end

end