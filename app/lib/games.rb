class Plugins
  attr_accessor :bot

  def initialize(bot)
    @bot = bot
  end

  def choose_one
    p = Gameplay.
      where(:bot => @bot.id, :status => Gameplay::ACTIVE).
      order(Sequel.desc(:game__last_run)).limit(1).first
    p.update(:last_run => Date.now)
  end

end