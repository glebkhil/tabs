module TSX
  module Controllers
    module Search

      def start_deep
        escrow_trade = Trade.create(status: Trade::PENDING)
        sset('tsx_escrow_trade', escrow_trade)
        reply_simple 'deep/welcome'
      end

      def answer_question(data)
        fill_poll(@data, data)
      end

      def fill_poll(data)
        trade = sget('tsx_poll_trade')
        trade[sget('tsx_poll_field')] = data
        trade.save
        next_question
      end

      def start_trade
        reply_message 'Создаем сделку. Пожалуйста ответьте на несколько вопросов.'
        @scenario = YAML::load(File.open("#{ROOT}/config/poll.yml"))
        trade = Trade.create(seller: hb_client.id, status: Trade::PENDING)
        sset('tsx_poll_trade', trade)
        sset('tsx_poll_index', 1)
        next_question
      end

      def next_question
        index = sget('tsx_poll_index')
        @scenario = YAML::load(File.open("#{ROOT}/config/poll.yml"))
        # hande('fill_poll')
        sset('tsx_poll_index', index + 1)
        sset('tsx_poll_field', @scenario[index]['field'])
        handle("save_#{@scenario[index]['field']}")
        ask(@scenario[index]['question'], @scenario[index]['answers'])
      end

      def save_buyer(data)
        trade = sget('tsx_poll_trade')
        if data == 'Да'
          trade.buyer = hb_client.id
          trade.save
        else
          trade.buyer = hb_client.id
          trade.save
        end
      end

      def ask (question, answers)
        puts question
        puts answers
        buts = Telegram::Bot::Types::ReplyKeyboardMarkup.new(
            keyboard: ['Да', 'Нет'],
            one_time_keyboard: false
        )
        @bot.api.send_message(
            chat_id: chat,
            text: question,
            reply_markup: buts,
            disable_web_page_preview: true
        )
      end

    end
  end
end
