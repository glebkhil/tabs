module TSX
  module Controllers
    module Wallet

      def panel
        reply_simple 'panel/index', layout: hb_layout
      end

      def cashout(data = nil)
        if data.nil?
          reply_simple 'panel/cashout', layout: hb_layout
        else

        end
      end


    end
  end
end
