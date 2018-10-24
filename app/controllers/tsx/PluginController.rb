module TSX
  module Controllers
    module Plugin

      def save_voting(data = nil)
        Vote.create(
            bot: @tsx_bot.id,
            username: hb_client.username
        )
        update_message "#{icon(@tsx_bot.icon_success)} Спасибо! Ваш голос очень важен, так как он участвует в голосовании за *Лучший Бот Месяца*. Лучший бот будет особо отмечен на странице *Рекомендуем*. Всего в этом месяце проголосовало *#{ludey(Vote::voted_this_month)}*."
      end

      def save_lottery(data)
        gam = sget('tsx_game')
        Bet.create(
            number: data.to_i,
            client: hb_client.id,
            game: gam.id
        )
        update_message "#{icon(@tsx_bot.icon_success)} Вы выбрали число *#{data}*. Когда рулетка закончится, победитель получит *#{@tsx_bot.amo(gam.conf('amount'))}*"
        prize_lottery(Gameplay.find(bot: @tsx_bot.id, title: 'lottery', status: Gameplay::ACTIVE))
      end

      def save_question
        Answer.create(
            answer: data.to_s,
            client: hb_client.id,
            game: @tsx_bot.active_game.id
        )
        update_message "#{icon(@tsx_bot.icon_success)} Вы поучаствовали в опросе клиентоа. Ваше мнение для нас важно!*."
      end

      def prize_lottery(game)

        puts "FINISH LOTTERY".blue
        if game.title == 'lottery'
          puts "FINISH LOTTERY".blue
          puts "AVAILALBE: #{game.available_numbers}"
          if game.available_numbers.nil? or game.available_numbers.count < 1
            puts "FINISH LOTTERY".blue
            rec = Bet.where(game: game.id).limit(1).order(Sequel.lit('RANDOM()')).all
            winner = Client[rec.first.client]
            winner_num = Bet[rec.first.id].number
            game.winner = winner.id
            game.save
            @tsx_bot.say(winner.tele, "🚨🚨🚨 *Поздравляем!* Выбранный Вами номер *#{winner_num}* выиграл в рулетку! Вы получили *#{@tsx_bot.active_game.conf('prize')}*. Ждем в Аптеке всегда!")
            winner.cashin(@tsx_bot.active_game.conf('amount'), Client::__cash, Meth::__cash, @tsx_bot.beneficiary, "Выигрыш в рулетку. Победа числа *#{winner_num}*.")
            Spam.create(bot: @tsx_bot.id, kind: Spam::BOT_CLIENTS, label: 'Победа числа в лотерею', text: "🚨🚨🚨 Дорогие друзья! Победило число *#{winner_num}*. Клиенту с ником @#{winner.username} пополнен баланс на #{@tsx_bot.active_game.conf('amount')}", status: Spam::NEW)
            puts "DEACTIVATING GAME".colorize(:white_on_red)
            game.update(status: Gameplay::GAMEOVER)
          end
        end
      end

      def play_game
        cur_game = @tsx_bot.active_game
        cur_game.update(last_run: Time.now) if !cur_game.nil?
        puts cur_game.inspect
        if cur_game.nil?
          puts "GAME IS NIL".blue
          serp
        elsif !cur_game.can_post?(hb_client)
          puts "CANNOT POST NOW".blue
          serp
        else
          puts "CANPOST. UPDATING GAME LAST RUN".blue
          sset("tsx_game", cur_game)
          reply_inline "welcome/#{cur_game.title}", gam: cur_game, b: @tsx_bot
          cur_game.inc
          puts "QUESTION? #{cur_game.question?}"
          if !cur_game.question?
            puts "NOT A QUESTION".blue
            serp
          else
            handle("save_game_res")
          end
        end
      end

      def save_game_res(data = nil)
        gam = sget('tsx_game')
        puts gam.inspect
        puts "calling save_#{gam.title} method".blue
        public_send("save_#{gam.title}".to_sym, data.to_s)
        sdel('tsx_game')
        serp
      end

    end
  end
end
