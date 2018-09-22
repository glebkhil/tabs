module TSX
  module Extension

    module Seller

      def seller_items
        Item.where(bot: self.id)
      end

      def seller_sold_items
        Trade.where(bot: self.id, trade__status: [Trade::FINISHED, Trade::FINALIZED])
      end

      def seller_turnover
        Trade.
          join(:item, item__id: :trade__item).
          where(item__bot: self.id, trade__status: [Trade::FINISHED, Trade::FINALIZED]).
          sum(:amount)
      end

      def seller_commissions
        Trade.
          join(:item, item__id: :trade__item).
          where(item__bot: self.id, trade__status: [Trade::FINISHED, Trade::FINALIZED]).
          sum(:commission)
      end

    end

  end
end