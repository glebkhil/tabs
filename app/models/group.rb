class Group < Sequel::Model(:group)
  ACTIVE = 1
  INACTIVE = 0

  def has_campaign?(bot)
    Campaign.
        join(:spam, :spam__id => :campaign__spam).
        join(:bot, :bot__id => :spam__bot).
        where(:campaign__group => self.id, :bot__client => bot.beneficiary).nil?
  end

  def campaign_by(bot)
    c = Campaign.dataset.
          select(Sequel.as(:campaign__id, :camp), Sequel.as(:campaign__spam, :spam)).
          join(:spam, :spam__id => :campaign__spam).
          join(:bot, :bot__id => :spam__bot).
          where(:campaign__group => self.id, :bot__id => bot.id)
    Campaign[c.map(:camp)[0]]
  end

  def configuration
    eval(self.config)
  end

  def my?(cl)
    if !self.client.nil?
      if cl.me?(cl)
        self.client == cl.id
      end
    else
      false
    end
  end

end