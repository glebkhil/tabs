module Darkside
  class System

    def self.item_total
      Item.where(status: Item::ACTIVE).count
    end

    def self.client_total
      Client.distinct(:username).count
    end

    def self.not_paid_by_day(day)
      Ledger.where(
          ledger__credit: Client::__commission.id,
          created: day - 1.day .. day
      ).sum(:amount) || 0
    end

    def self.sales_count_by_day(day)
      Trade.where(closed: day - 1.day .. day).count(:id)
    end

    def self.sales_amount_by_day(day)
      Trade.where(closed: day - 1.day .. day).sum(:amount)
    end

    def self.shop_total
      Bot.where(listed: 1).count(:id)
    end

    def self.today_turnover
      by_bot = []
      Bot.where(status: Bot::ACTIVE).each do |b|
        by_bot << b.id
      end
      Ledger.
          join(
              :client, client__id: :ledger__credit
          ).where(
            ledger__created: (Date.today - 1.day)..Date.today,
            client__bot: by_bot
      ).sum(:amount)
    end

    def self.turnover
      Trade.where(closed: Date.today.beginning_of_month - 1.day .. Date.today.end_of_month)
    end

  end
end