module TSX
  module Controllers
    module Search

      def start_btc
        reply_simple 'btc/welcome'
        reply_inline 'btc/wallets', wallets: Servicewallet.where(status: Servicewallet::ACTIVE)
      end

      def service_wallets
        reply_inline 'btc/wallets', wallets: Servicewallet.where(status: Servicewallet::ACTIVE)
      end

    end
  end
end
