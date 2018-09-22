class Rank < Sequel::Model(:rank)

  def self.buyer(client)
    sum = Rank.dataset.
      select{[count(:rank__id), sum(:rank__rank)]}.
      join(:trade, trade__id: :rank__trade).
      where(trade__buyer: client.id)
    count = sum.map(:count)[0]
    sum = sum.map(:sum)[0]
    begin
      (sum / count).to_f
    rescue
      return 0.0
    end
  end

  def self.seller(client)
    sum = Rank.dataset.
      select{[count(:rank__id), sum(:rank__rank)]}.
      join(:trade, trade__id: :rank__trade).
      where(trade__seller: client.id)
    count = sum.map(:count)[0]
    sum = sum.map(:sum)[0]
    begin
      (sum / count).to_f
    rescue
      return 0.0
    end
  end

  def self.reputation(client)
    ranks = Rank.where(seller: client.id).count
    rank_sum = Rank.where(seller: client.id).sum(:rank)
    begin
      puts "REPUTATION".colorize(:yellow)
      puts (rank_sum.to_f / ranks.to_f).inspect
      (rank_sum.to_f / ranks.to_f).round(3)
    rescue
      return 0.1
    end
  end

  def self.negative(client)
    Rank.where(seller: client.id, rank: [1, 2, 3]).count
  end

  def self.positive(client)
    Rank.where(seller: client.id, rank: [4, 5]).count
  end

  # def self.ranks(client)
  #   Rank.dataset.
  #       join(:trade, :trade__id => :rank__trade).
  #       where{(buyer = client.id.to_i or seller = client.id.to_i)}
  # end

  def self.rank_by_trade(trade)
    d = Rank.dataset.
      select(Sequel.as(:rank__rank, :rnk)).
      join(:trade, trade__id: :rank__trade).
      where(trade__id: trade.id)
    d.map(:rnk)[0] || 'нет оценки'
  end


end