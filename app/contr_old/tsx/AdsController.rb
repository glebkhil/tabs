module TSX
  module Controllers
    module Search

      def activate_darkside
        reply_simple 'ads/welcome'
      end

      def assign_to_client
        reply_simple 'ads/ask_token'
      end

    end
  end
end
