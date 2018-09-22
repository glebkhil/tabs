module TSX
  module Controllers
    module Search

      def start_tab
        reply_simple 'tab/welcome'
      end

      def cancel_new_bot
        bname = sget('tab_new_bot_clear_name')
        reply_message 'Создание бота отменено.'
        bot = Bot.find(tele: bname)
        if !bot.nil?
          bot.delete
        end
        start_tab
      end

      def new_bot(data = nil)
        if data
          matched = data.match(/(.*)(_bot|Bot|BOT|_BOT|_Bot)/)
          if !matched
            reply_message "#{icon(@tsx_bot.icon_info)} Имя бота должно быть полным, включая слово `bot` или `_bot`."
          else
            botname = matched.captures.first
            if !Bot.find(tele: botname).nil?
              reply_message "#{icon(@tsx_bot.icon_info)} Такой бот уже зарегистрирован."
            else
              sset('tab_new_bot_clear_name', botname)
              sset('tab_new_bot_underscored', data.include?("_") ? 1 : 0)
              new_bot_token
            end
          end
        else
          handle('new_bot')
          reply_simple 'tab/name'
        end
      end

      def new_bot_token(data = nil)
        handle('new_bot_token')
        if data
          sset('tab_new_bot_token', data)
          create_bot
        else
          reply_simple 'tab/token'
        end
      end

      def create_bot
        botname = sget('tab_new_bot_clear_name')
        token = sget('tab_new_bot_token')
        underscored = sget('tab_new_bot_underscored')
        puts "BOTNANE #{botname}".colorize(:light_blue)
        puts "TOKEN #{token}".colorize(:light_blue)
        begin
          @conn ||= Faraday.new(url: 'https://api.telegram.org') do |faraday|
            faraday.request :json
            faraday.adapter Telegram::Bot.configuration.adapter
          end
          from_bot = Telegram::Bot::Api.new(token)
          from_bot.setWebhook(url: "https://#{@tsx_host}/hook/#{token}")

          bene = Client.create(
              tele: '1',
              username: "__bot_#{botname}"
          )

          bot = Bot.create(
              tele: botname,
              token: token,
              title: botname,
              underscored_name: underscored,
              serp_type: Bot::SERP_PRODUCT_FIRST,
              web_klad: 0,
              status: Bot::ACTIVE
          )

          bot.set_var('country', 2)

          Team.create(
              bot: bot.id,
              client: bene.id,
              role: Client::HB_ROLE_SELLER
          )
          admin = bot.add_operator(hb_client, Client::HB_ROLE_ADMIN)
          finish_name = sget('tab_new_bot_underscored') ? '_bot' : 'bot'
          bot_full_name = "@#{bot.tele}#{finish_name}"
          puts bot_full_name
          reply_simple 'tab/created', links: false, is_production: ENV['RACK_ENV'] == 'production', botname: bot_full_name, b: bot, token: admin.token, username: Client[admin.client].username
        rescue => e
          puts e.message
          reply_message 'Не удалось создать бот. Проверьте ваш API токен.'
        end
      end
    end
  end
end
