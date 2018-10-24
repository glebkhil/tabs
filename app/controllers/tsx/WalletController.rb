module TSX
  module Controllers
    module Wallet

      def panel
        # reply_simple 'panel/index', layout: hb_layout
      end

      def cashout
        # hanlder('accept_cashout')
        # reply_simple 'panel/cashout', layout: hb_layout
      end

      def accept_cashout(data)
        # Cashout.create(client: hb_client.id, details: data, status: 1)
        # reply_update '❣️ Ваша звявка принята. В течние двух дней деньги будут у Вас. Спасибо, что работаете с нами.'
      end

      def client_statement
        # reply_simple 'panel/statement', layout: hb_layout
      end


    end
  end
end
