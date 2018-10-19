module TSX
  module Plugins

    def voting(data = nil)
      raise 'Voting not allowed' if !Voting.new.game_allowed?(@tsx_bot, hb_client)
      if callback_query?
        Vote.create(
            bot: data.to_i,
            username: hb_client.tele
        )
        update_message "#{icon(@tsx_bot.icon_success)} Спасибо! Ваш голос очень важен, так как он участвует в голосовании за *Лучший Бот Месяца*. Лучший бот будет особо отмечен на странице *Рекомендуем*. Всего в этом месяце проголосовало *#{ludey(Vote::voted_this_month)}*."
        serp
      else
        handle('voting')
        reply_inline 'welcome/vote'
      end
    end

    def lottery(data = nil)
      raise 'Betting not allowed' if !Lottery.new.game_allowed?(@tsx_bot, hb_client)
      if callback_query?
        Bet.create(
            number: data.to_s,
            client: hb_client.id,
            game: @tsx_bot.active_game.id
        )
        update_message "#{icon(@tsx_bot.icon_success)} Вы выбрали число *#{data}*. Когда рулетка закончится, победитель получит *#{@tsx_bot.active_game.conf('prize')}*."
        @gam = @tsx_bot.active_game
        puts "NUMBERS COUNT: #{@gam.available_numbers.count}".colorize(:red)
        if @gam.available_numbers.count < 1
          rec = Bet.where(game: @gam.id).limit(1).order(Sequel.lit('RANDOM()')).all
          winner = Client[rec.first.client]
          winner_num = Bet[rec.first.id].number
          @gam.winner = winner.id
          @gam.save
          @tsx_bot.say(winner.tele, "🚨🚨🚨 *Поздравляем!* Выбранный Вами номер *#{winner_num}* выиграл в рулетку! Вы получили *#{@tsx_bot.active_game.conf('prize')}*. Ждем в Аптеке всегда!")
          winner.cashin(@tsx_bot.active_game.conf('amount'), Client::__cash, Meth::__cash, @tsx_bot.beneficiary, "Выигрыш в рулетку. Победа числа *#{winner_num}*.")
          Spam.create(bot: @tsx_bot.id, kind: Spam::BOT_CLIENTS, label: 'Победа числа в лотерею', text: "🚨🚨🚨 Дорогие друзья! Победило число *#{winner_num}*. Клиенту с ником @#{winner.username} пополнен баланс на #{@tsx_bot.active_game.conf('amount')}", status: Spam::NEW)
          puts "DEACTIVATING GAME".colorize(:white_on_red)
          Gameplay.find(status: Gameplay::ACTIVE, bot: @tsx_bot.id).update(status: Gameplay::GAMEOVER)
        end
        serp
      else
        @gam = @tsx_bot.active_game
        handle('lottery')
        reply_inline 'welcome/lottery', gam: @gam
      end
    end

  end
end
