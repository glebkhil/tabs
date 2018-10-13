class Vote < Sequel::Model(:vote)

  def self.voted_this_month
    Vote.where(created: Date.today.beginning_of_month .. Date.today.end_of_month).count(:id)
  end

  def self.best_this_month
    bot = Vote.
      select(Sequel.as(:vote__bot, :bot), Sequel.as(Sequel.function('sum', :vote__id), :cnt)).
      where(created: Date.today.beginning_of_month .. Date.today.end_of_month).
      group(:bot).order(Sequel.desc(:cnt)).limit(1).first[:bot]
    Bot[bot]
  end

end