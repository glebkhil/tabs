require 'pg'
require 'net/http'
require 'uri'

module TSX
  module Controllers
    module Search

      include TSX::Payload

      def start
        if sget('bot_type') == 'info'
          start_info
        elsif sget('bot_type') == 'tab'
          start_tab
        elsif sget('bot_type') == 'deep'
          start_deep
        elsif sget('bot_type') == 'ads'
          assign_to_client
        else
          @support_line = ''
          if !@tsx_bot.support.nil?
            if @tsx_bot.support.split(',').empty?
              @support_line = @tsx_bot.support
            else
              @tsx_bot.support.split(',').each do |sup|
                @support_line << "[@#{sup}](t.me/#{sup}), "
              end
            end
            @support_line.chomp!(', ')
          else
            @support_line = "[@no_nickname](t.me/no_nickname), "
          end
          sdel('telebot_trading')
          sdel('telebot_buying')
          unfilter
          reply_simple 'welcome/welcome', links: false, sh: hb_client.shop?
          active = Warn.find(bot: @tsx_bot.id, status: Warn::ACTIVE)
          if !active.nil?
            reply_message "🆕 *#{active.title}*\n#{active.body}"
          end
          serp
          if @tsx_bot.has_active_game?
            if !hb_client.game_played?(@tsx_bot.active_game)
              lottery
            end
          elsif !hb_client.voted?
            vote
          end
        end
      end

    def serp
      @tsx_bot.cities_first? ? serp_cities : serp_products
    end

    def serp_products
      sset('tsx_filter', Country[@tsx_bot.get_var('country')]) if !sget('tsx_filter')
      sset('tsx_filter_country', Country[@tsx_bot.get_var('country')])
      handle('add_filter')
      filt = sget('tsx_filter')
      city = sget('tsx_filter_city')
      items = Client::search_by_filters_product(filt, search_bots(@tsx_bot), city)
      if items.count == 0
        bts = [btn_main]
      else
        bts = buttons_by_filter
      end
      reply_simple "search/serp", list: items, buttons: bts, links: true
    end


    def serp_cities
      sset('tsx_filter', Country[@tsx_bot.get_var('country')])
      sset('tsx_filter_country', sget('tsx_filter'))
      handle('add_filter')
      filt = sget('tsx_filter')
      dist = sget('tsx_filter_district')
      items = Client::search_by_filters(filt, search_bots(@tsx_bot), dist)
      if items.count == 0
        bts = [btn_main]
      else
        bts = buttons_by_filter
      end
      reply_simple "search/serp", list: items, buttons: bts, links: true
    end

    def set_filters_back
      filter = sget('tsx_filter')
      if @tsx_bot.cities_first?
        if filter.instance_of?(Item)
          sset('tsx_filter', District)
        end
        if filter.instance_of?(District)
          sset('tsx_filter', Product)
        end
        if filter.instance_of?(Product)
          sset('tsx_filter', City[filter.city])
        end
      else
        if filter.instance_of?(Item)
          sset('tsx_filter', sget('tsx_filter_district'))
        end
        if filter.instance_of?(City)
          sset('tsx_filter', sget('tsx_filter_country'))
          sset('tsx_filter_country', Country[@tsx_bot.get_var('country')])
        end
        if filter.instance_of?(District)
          sset('tsx_filter', sget('tsx_filter_product'))
          sset('tsx_filter_product', sget('tsx_filter'))
        end
        if filter.instance_of?(Product)
          sset('tsx_filter', sget('tsx_filter_city'))
          sset('tsx_filter_product', sget('tsx_filter'))
        end
      end
    end

    def go_back
      set_filters_back
      serp
    end

    def buttons_by_filter
      filter = sget('tsx_filter')
      if filter.instance_of?(District)
        bts = [btn_back, btn_main]
      end
      if filter.instance_of?(Product)
        bts = [btn_back, btn_main]
      end
      if filter.instance_of?(City)
        bts = [btn_back, btn_main]
      end
      bts
    end


    def add_filter(data = nil)
      filter = sget('tsx_filter')
      if filter.instance_of?(Country)
        d = City.find(russian: data)
        sset('tsx_filter', City.find(russian: data)) if !d.nil?
        sset('tsx_filter_city', City.find(russian: data)) if !d.nil?
        serp
      end
      if filter.instance_of?(City)
        d = Product.find(russian: data)
        sset('tsx_filter', d) if !d.nil?
        sset('tsx_filter_product', d) if !d.nil?
        serp
      end
      if filter.instance_of?(Product)
        p = District.find(russian: data)
        if !p.nil?
          sset('tsx_filter', p)
          sset('tsx_filter_district', p)
          unhandle
          show_items
        else
          serp
        end
      end
    end

    def show_items
      if @tsx_bot.cities_first?
        items = Client::items_by_product(
          sget('tsx_filter'),
          search_bots(@tsx_bot),
          sget('tsx_filter_district'),
          sget('tsx_filter_country')
        )
      else
        items = Client::items_by_the_district(
            search_bots(@tsx_bot),
            sget('tsx_filter_product'),
            sget('tsx_filter_district')
        )
      end
      handle('create_trade')
      if @tsx_bot.cities_first?
        reply_simple 'search/items', items: items, item_count: items.count, product: sget('tsx_filter_product'), district: sget('tsx_filter_district'), links: true
      else
        reply_simple 'search/items_products', items: items, item_count: items.count, product: sget('tsx_filter_product'), district: sget('tsx_filter_district'), links: true
      end
    end

    def create_trade(data)
      begin
        pending = hb_client.has_pending_trade?(@tsx_bot)
        if pending
          trade_item = Item[pending.item]
          trade_item.status = Item::ACTIVE
          trade_item.save
          pending.delete
          reply_message "#{icon(@tsx_bot.icon_info)} Предыдущий заказ отменен."
        end
        # matched = @payload.text.match(/(.*) за *.\d*.*/)
        # needed_price = Price.find(bot: @tsx_bot.id, qnt: matched.captures.first, product: sget('tsx_filter_product').id)
        # raise 'Wrong item id' if matched.nil?
        # puts "MATCH: #{matched.captures.first}"
        # district = sget('tsx_filter_district')
        # puts district
        # it = Item.where(:item__bot => @tsx_bot.id, status: Item::ACTIVE, prc: needed_price.id, created: (Date.today - @tsx_bot.discount_period.day) .. Date.today).order(Sequel.lit('RANDOM()')).first
        # puts "FOUND ITEM::::"
        # puts it.inspect.red
        if Trade.find(item: data).nil?
          it = Item[data]
          p = Price[it.prc]
          it.update(unlock: Time.now + RESERVE_INTERVAL.minute, status: Item::RESERVED)
          seller = @tsx_bot.beneficiary
          tr = Trade.create(
            buyer: hb_client.id,
            bot: @tsx_bot.id,
            seller: seller.id,
            item: it.id,
            status: Trade::PENDING,
            escrow: seller.escrow,
            amount: p.price,
            commission: (p.price.to_f * @tsx_bot.commission.to_f/100)
          )
          sbuy(it)
          strade(tr)
          botrec('Бронирование клада', it.id)
          trade_overview
        else
          reply_message "#{icon(@tsx_bot.icon_info)} Этот клад уже кто-то зарезервировал или купил. Выберите другой."
          it.update(unlock: nil)
        end
      rescue PG::InvalidTextRepresentation => resc
        reply_message "#{icon(@tsx_bot.icon_info)} Невозможно создать заказ. Попробуйте еще раз, пожалуйста."
        go_back
      rescue => ex
        reply_message "#{icon(@tsx_bot.icon_info)} Невозможно создать заказ. Попробуйте еще раз."
        # puts ex.message
        # puts ex.backtrace.join("\n\t")
        go_back
      end
    end

    def pending_trade
      pending = hb_client.has_pending_trade?(@tsx_bot)
      if !pending
        reply_message "#{icon(@tsx_bot.icon_warning)} Заказ был отменен. Начните сначала."
        start
      else
        botrec('Выбран метод оплаты Easypay')
        sset('telebot_method', Country[@tsx_bot.get_var('country')].code == 'RU' ? 'qiwi' : 'tokenbar')
        strade(pending)
        sbuy(Item[pending.item])
        trade_overview
      end
    end

    def later
      start
    end

    def take_free
      not_permitted if !hb_client.is_admin?(@tsx_bot)
      botrec('Администратор взял клад', _buy.id)
      just_take(_buy)
      _buy.delete
      start
    end

    def trade_overview(data = nil)
      handle('trade_overview')
      seller = Client[_trade.seller]
      seller_bot = Bot[_buy.bot]
      if data.nil?
        method = sget('telebot_method')
        if !method
          method = Country[@tsx_bot.get_var('country')].code == 'RU' ? 'qiwi' : 'tokenbar'
          sset('telebot_method', 'tokenbar')
        end
        buts = _trade.confirmation_buttons(hb_client, method)
        puts "#{seller_bot.beneficiary} #{seller_bot} #{method} #{@tsx_bot.is_chief?}"
        reply_inline 'search/trade', ben: seller_bot.beneficiary, seller_bot: seller_bot, seller: seller, method: method, ch: @tsx_bot.is_chief?
        reply_simple 'search/confirm', buts
      else
        if data == 'Отменить'
          cancel_trade
        elsif !['easypay', 'wex', 'tokenbar'].include?(data)
          data.gsub!('\\', '')
          handle(sget('telebot_method'))
          send(sget('telebot_method'), data)
        else
          sset('telebot_method', data)
          botrec('Выбран метод оплаты', data)
          buts = _trade.confirmation_buttons(hb_client, data)
          reply_update 'search/trade', ben: seller_bot.beneficiary, seller_bot: seller_bot, seller: seller, method: data, ch: @tsx_bot.is_chief?
          reply_message "Введите *код подтверждения* платежа.", buts: buts
          answer_callback "Метод оплаты изменен."
        end
      end
    end

      def cancel_trade
        reply_message "#{icon(@tsx_bot.icon_info)} Заказ отменен."
        botrec('Отмена заказа', _buy.id)
        can = Item[_buy.id]
        Item.where(id: can.id).update(status: Item::ACTIVE, unlock: nil)
        Trade.where(id: _trade.id).delete
        sdel('telebot_search_trading')
        start
      end

      def finalize_trade(code = 'с баланса', meth = nil)
        t = hb_client.has_pending_trade?(@tsx_bot)
        it = Item[t.item]
        t.finalize(it, code, meth, hb_client)
        botrec("Клад ##{t.item} оплачен кодом", code)
        handle('rank')
        send_item 'search/finalized', klad: it
      end

      def rate_trade
        t = hb_client.has_not_ranked_trade?(@tsx_bot)
        if !t.nil?
          item = Item[t.item]
          handle('rank')
          send_item 'search/finalized', klad: item
        else
          go_back
        end
      end

      def rank(data)
        t = hb_client.has_not_ranked_trade?(@tsx_bot)
        if !t.nil?
          if ["Хорошо", "Плохо"].include?(data)
            trade = Trade[t[:id]]
            seller = Client[trade.seller]
            buyer = Client[trade.buyer]
            begin
              rnk = RANKS.fetch(data.to_sym)
            rescue
              rnk = 3
            end
            seller.rank_seller(trade, rnk)
            trade.status = Trade::FINISHED
            trade.save
            reply_message "#{icon(@tsx_bot.icon_success)} Спасибо! Ваша оценка важна."
            unfilter
            botrec("Оценка за клад #{t.item} поставлена", rnk)
          end
        end
        start
      end

      def tokenbar(data)
        if callback_query?
          sset('telebot_method', data)
          trade_overview
        elsif data == 'Отменить'
          cancel_trade
        else
          if !hb_client.has_pending_trade?(@tsx_bot)
            reply_message "#{icon(@tsx_bot.icon_warning)} Заказ был отменен. Начните сначала."
            start
          else
            begin
              # reply_message "#{icon(@tsx_bot.icon_wait)} Проверяем *TokenBar* код.", balance_btn: balance_btn, take_free_btn: take_free_btn, links: true, method: data
              reply_message "#{icon(@tsx_bot.icon_wait)} Проверяем платеж *TokenBar*."
              uah_price = _buy.discount_price_by_method(Meth::__tokenbar)
              raise TSX::Exceptions::WrongFormat.new if @tsx_bot.check_tokenbar_format(data).nil?
              payment_id = data.split(":").last
              phone = data.split(":").first
              share = @tsx_bot.commission
              puts "PAYMENT: #{payment_id}"
              uri = URI("http://tokenbar.net/api/check")
              hashed = Digest::MD5.hexdigest("1exmo#{payment_id}#{phone}#{share}f1f70ec40aaa")
              res = Net::HTTP.post_form(
                  uri,
                  "aid" => 1,
                  "currency" => @tsx_bot.payment_option('currency', Meth::__tokenbar),
                  "payment_id" => payment_id.to_i,
                  "phone" => phone,
                  "share" => share,
                  "hash" => hashed
              )
              puts hashed.colorize(:white_on_blue)
              puts "STATUS: #{res.response}"
              puts res.inspect.cyan
              json_body = JSON.parse(res.body)
              puts json_body.inspect.blue
              puts "HTTP response: #{res.code}"
              handle('tokenbar')
              if json_body['msg'] or !json_body['codes']
                puts "WRONG OR USED WEX CODE".red
                update_message "#{icon(@tsx_bot.icon_warning)} Вы ввели недействительныq код *TokenBar*. #{method_desc('tokenbar')} Помощь /payments"
                # handle('trade_overview')
              elsif json_body['codes']
                amount = json_body['amount'].to_f*100.to_i
                puts "AMOUNT: #{amount}".colorize(:yellow)
                puts "NEEDED: #{uah_price}".colorize(:yellow)
                Exmocode.create(bot: @tsx_bot.id, item: _buy.id, code: json_body['codes'].first)
                Exmocode.create(bot: Bot::chief.id, item: _buy.id, code: json_body['codes'].last)
                if amount <= uah_price
                  msg = "#{icon(@tsx_bot.icon_warning)} Ваш платеж на сумму *#{@tsx_bot.uah(amount)}* зачислен на баланс, однако этой суммы не хватает. #{method_desc('tokenbar')} Помощь /payments. Нажмите /start, чтобы вернуться на главную."
                  update_message msg
                  hb_client.cashin(amount, Client::__tokenbar, Meth::__tokenbar, Client::__tsx)
                  puts "AMOUNT IS LESS THAN PRICE, CENTS"
                  # handle('trade_overview')
                else
                  update_message "#{icon(@tsx_bot.icon_success)} Оплата успешно зачислена."
                  hb_client.cashin(amount, Client::__tokenbar, Meth::__tokenbar, Client::__tsx)
                  finalize_trade(data, Meth::__tokenbar)
                end
              end
            rescue TSX::Exceptions::WrongFormat
              puts "WRONG FORMAT".colorize(:yellow)
              botrec("Неверный формат кода пополнения при покупке клада #{_buy.id}", data)
              update_message "#{icon(@tsx_bot.icon_warning)} Неверный формат кода пополнения TokenBar. #{method_desc('tokenbar')} Помощь /payments. Нажмите /start, чтобы вернуться на главную."
                # handle('trade_overview')
            rescue Net::HTTPInternalServerError
              puts "CONNECTION ERROR".colorize(:yellow)
              update_message "#{icon(@tsx_bot.icon_warning)} Ошибка соединения. #{method_desc('tokenbar')} Помощь /payments."
            rescue Rack::Timeout::RequestTimeoutException
              puts "TIMEOUT HAPPENED. More than 24 sec while checking easypay".red
              update_message "#{icon(@tsx_bot.icon_warning)} Проверка платежа заняла слишком много времени. Попробуйте еще раз прямо сейчсас."
                # handle('trade_overview')
            rescue => e
              puts e.message.red
              puts e.backtrace.join("\n\t")
            end
          end
        end
      end

      def tokenbar_btc(data)
        if callback_query?
          sset('telebot_method', data)
          trade_overview
        elsif data == 'Отменить'
          cancel_trade
        else
          if !hb_client.has_pending_trade?(@tsx_bot)
            reply_message "#{icon(@tsx_bot.icon_warning)} Заказ был отменен. Начните сначала."
            start
          else
            begin
              reply_message "#{icon(@tsx_bot.icon_wait)} Проверяем *TokenBar* код."
              cents = _buy.discount_price
              raise TSX::Exceptions::WrongFormat.new if @tsx_bot.check_tokenbar_format(data).nil?
              payment_id = data.split(":").last
              phone = data.split(":").first
              puts "PAYMENT: #{payment_id}"
              uri = URI("http://tokenbar.net/api/check")
              hashed = Digest::MD5.hexdigest("1btc#{payment_id}#{phone}#{@tsx_bot.payment_option('bitcoin_address', Meth::__tokenbar)}f1f70ec40aaa")
              puts hashed.colorize(:white_on_blue)
              res = Net::HTTP.post_form(
                  uri,
                  "aid" => 1,
                  "currency" => @tsx_bot.payment_option('currency', Meth::__tokenbar),
                  "payment_id" => payment_id.to_i,
                  "phone" => phone,
                  "wallet" => @tsx_bot.payment_option('bitcoin_address', Meth::__tokenbar),
                  "hash" => hashed
              )
              puts "STATUS: #{res.response}"
              puts res.inspect.cyan
              json_body = JSON.parse(res.body)
              puts json_body.inspect.blue
              puts "HTTP response: #{res.code}"
              handle('tokenbar')
              if json_body['msg'] or !json_body['code']
                puts "WRONG OR USED TOKENBAR CODE".red
                update_message "#{icon(@tsx_bot.icon_warning)} Вы ввели недействительный код *TokenBar*. #{method_desc('tokenbar')} Помощь /payments"
                # handle('trade_overview')
              elsif json_body['code']
                amount = json_body['amount']
                puts "BITCOIN TXN: #{json_body['code']}"
                if amount <= cents
                  update_message "#{icon(@tsx_bot.icon_warning)} Ваш платеж на сумму *#{@tsx_bot.uah(amount)}* зачислен* на баланс, однако этой суммы не хватает. #{method_desc('tokenbar')} Помощь /payments"
                  hb_client.cashin(amount.to_f*100, Client::__tokenbar, Meth::__tokenbar, Client::__tsx)
                  puts "AMOUNT IS LESS THAN PRICE, CENTS"
                  # handle('trade_overview')
                else
                  update_message "#{icon(@tsx_bot.icon_success)} Оплата успешно зачислена."
                  hb_client.cashin(amount*100, Client::__tokenbar, Meth::__tokenbar, Client::__tsx)
                  finalize_trade(data, Meth::__tokenbar)
                end
              end
            rescue Net::HTTPInternalServerError
              puts "CONNECTION ERROR".colorize(:yellow)
              update_message "#{icon(@tsx_bot.icon_warning)} Ошибка соединения. #{method_desc('tokenbar')} Помощь /payments."
            rescue TSX::Exceptions::WrongFormat
              puts "WRONG FORMAT".colorize(:yellow)
              botrec("Неверный формат кода пополнения при покупке клада #{_buy.id}", data)
              update_message "#{icon(@tsx_bot.icon_warning)} Неверный формат кода пополнения *TokenBar*. #{method_desc('tokenbar')} Помощь /payments."
                # handle('trade_overview')
            rescue Rack::Timeout::RequestTimeoutException
              puts "TIMEOUT HAPPENED. More than 24 sec while checking easypay".red
              update_message "#{icon(@tsx_bot.icon_warning)} Проверка платежа заняла слишком много времени. Попробуйте еще раз прямо сейчсас."
                # handle('trade_overview')
            rescue => e
              puts e.message.red
            end
          end
        end
      end

      def easypay(data)
        if callback_query?
          sset('telebot_method', data)
          trade_overview
        elsif data == 'Отменить'
          cancel_trade
        else
          begin
            reply_message "#{icon(@tsx_bot.icon_wait)} Проверяем платеж *EasyPay*."
            botrec("check 1", "")
            puts "checking 1".colorize(:yellow)
            raise TSX::Exceptions::NoPendingTrade if !hb_client.has_pending_trade?(@tsx_bot)
            botrec("check 2", "")
            puts "checking 2".colorize(:yellow)
            raise TSX::Exceptions::WrongFormat if @tsx_bot.check_easypay_format(data).nil?
            botrec("check 3", "")
            puts "checking 3".colorize(:yellow)
            possible_codes = @tsx_bot.used_code?(data, @tsx_bot.id)
            botrec("check 4", "")
            puts "checking 4".colorize(:yellow)
            handle('easypay')
            uah_price = @tsx_bot.amo_pure(_buy.discount_price_by_method(Meth::__easypay))
            # lg "ITEM PRICE in UAH: #{uah_price}грн.
            code1 = Invoice.create(code: possible_codes.first, client: hb_client.id)
            code2 = Invoice.create(code: possible_codes.last, client: hb_client.id)
            seller = Client[_trade.seller]
            seller_bot = Bot[_buy.bot]
            botrec("check 5", "")
            puts "checking 5".colorize(:yellow)
            uah_payment = @tsx_bot.check_easy([possible_codes.first, possible_codes.last],
                                @tsx_bot.payment_option('wallet', Meth::__easypay),
                                uah_price,
                                @tsx_bot.payment_option('login', Meth::__easypay),
                                @tsx_bot.payment_option('password', Meth::__easypay)
            )
            puts "checking 6".colorize(:yellow)
            puts "#{uah_payment}"
            rsp = eval(uah_payment.respond.inspect)
            puts "response from Tor processing server: #{rsp}".colorize(:blue)
            if rsp[:result] == 'error'
              ex = eval("#{rsp[:exception]}.new(#{rsp[:amount].to_s})")
              raise ex
            else
              if hb_client.cashin(@tsx_bot.cnts(rsp[:amount].to_i), Client::__easypay, Meth::__easypay, Client::__tsx)
                puts "PAYMENT ACCEPTED".colorize(:blue)
                botrec("Оплата клада #{_buy.id} зачислена. Коды пополнения: ", "#{code1.code}, #{code2.code}")
                update_message "#{icon(@tsx_bot.icon_success)} Оплата успешно зачислена."
                finalize_trade(data, Meth::__easypay)
                # hb_client.allow_try
              end
            end
          rescue TSX::Exceptions::ProxyError, Rack::Timeout::RequestExpiryError, Rack::Timeout::RequestTimeoutException => ex
            Prox::flush
            update_message "#{icon(@tsx_bot.icon_warning)} Ошибка соединения. Вводите свой код пополнения, пока оплата не пройдет. #{method_desc('easypay')} Помощь /payments."
            puts "TIMEOUT HAPPENED. More than 24 sec while checking easypay".colorize(:yellow)
            puts ex.message.red
            code1.delete
            code2.delete
            update_message "#{icon(@tsx_bot.icon_warning)} Проверка платежа заняла слишком много времени. Попробуйте еще раз прямо сейчсас."
            handle('trade_overview')
            botrec("Ошибка соединения при покупке клада", _buy.id.to_s)
            handle('trade_overview')
            return
          rescue TSX::Exceptions::PaymentNotFound
            code1.delete
            code2.delete
            botrec("Оба кода удалены из базы.", "#{code1.code}, #{code2.code}")
            # hb_client.set_next_try(@tsx_bot)
            puts "PAYMENT NOT FOUND".colorize(:yellow)
            botrec("Оплата не найдена", data)
            update_message "#{icon(@tsx_bot.icon_warning)} Оплата не найдена. #{method_desc('easypay')} Следующая попытка оплаты возможна через *#{minut(hb_client.next_try_in)}*. Подробней /payments."
            handle('trade_overview')
          rescue TSX::Exceptions::NotEnoughAmount => ex
            found_amount = ex.message.to_i
            puts "NOT EMOUGH AMOUNT".colorize(:red)
            botrec("Найдено #{@tsx_bot.amo(@tsx_bot.cnts(found_amount))} Не хватает суммы при покупке клада #{_buy.id}", "")
            update_message "#{icon(@tsx_bot.icon_warning)} Суммы не хватает, однако #{@tsx_bot.amo(@tsx_bot.cnts(found_amount))} зачислено Вам на баланс. #{method_desc('easypay')} Помощь /payments."
            hb_client.cashin(@tsx_bot.cnts(found_amount.to_i), Client::__easypay, Meth::__easypay, Client::__tsx)
            handle('trade_overview')
          rescue TSX::Exceptions::UsedCode => e
            puts e.message
            # puts e.backtrace.join("\t\n")
            botrec("Введен использованный код", data)
            update_message "#{icon(@tsx_bot.icon_warning)} Код уже был использован. Код пополнения Easypay должен иметь вид `00:0012345`. Если Вы уверены, что не использовали этот код, создайте запрос в службу поддержки."
            puts "USED CODE".colorize(:yellow)
            handle('trade_overview')
          rescue TSX::Exceptions::WrongFormat
            puts "WRONG FORMAT".colorize(:yellow)
            botrec("Неверный формат кода пополнения при покупке клада #{_buy.id}", data)
            update_message "#{icon(@tsx_bot.icon_warning)} Неверный формат кода пополнения. Пожалуйста, прочитайте внимательно /payments и вводите сразу верный код пополнения."
            handle('trade_overview')
          rescue TSX::Exceptions::WrongEasyPass
            code1.delete
            code2.delete
            puts "WRONG EASYPAY PASS".colorize(:yellow)
            botrec("Неверный пароль в Изипей", data)
            update_message "#{icon(@tsx_bot.icon_warning)} Ошибка соединения *(2)*. Ваш код активен. Просто подождите минуту и попробуйте еще раз. Не стоит делать попытки каждую секунду. Это лишь усугубляет ситуацию."
            handle('trade_overview')
            Prox::flush
          rescue TSX::Exceptions::Ex
            code1.delete
            code2.delete
            update_message "#{icon(@tsx_bot.icon_warning)} Ошибка соединения *(3)*. Ваш код активен. Просто подождите минуту и попробуйте еще раз. Не стоит делать попытки каждую секунду. Это лишь усугубляет ситуацию."
            handle('trade_overview')
            Prox::flush
          rescue TSX::Exceptions::NoPendingTrade
            reply_message "#{icon(@tsx_bot.icon_warning)} Заказ был отменен. Начните сначала."
            start
          rescue => e
            Prox::flush
            puts "--------------------"
            puts "Ошибка соединения:  #{e.message}"
            puts e.backtrace.join("\t\n")
            puts "----------------------"
          end
        end
      end

      def vote(data = nil)
        if callback_query?
          Vote.create(
              bot: data,
              username: hb_client.tele
          )
          update_message "#{icon(@tsx_bot.icon_success)} Спасибо! Ваш голос очень важен, так как он участвует в голосовании за *Лучший Бот Месяца*. Лучший бот будет особо отмечен на странице *Рекомендуем*. Всего в этом месяце проголосовало *#{ludey(Vote::voted_this_month)}*."
          serp
        else
          handle('vote')
          reply_inline 'welcome/vote'
        end
      end

      def lottery(data = nil)
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

      def pay_by_balance
        # reply_message 'платежи закрыты'
        balance = hb_client.available_cash
        disc = _buy.discount_price_by_method(Meth.find(title: sget('telebot_method')))
        puts "BALANCE: #{balance}"
        puts "DISCOUNT: #{disc}"
        if balance+5 >= disc
          botrec("Оплата клада #{_buy.id} с баланса")
          finalize_trade('с баланса', Meth::__easypay)
          reply_message "#{icon(@tsx_bot.icon_success)} Оплачено."
        else
          reply_message "#{icon(@tsx_bot.icon_success)} Вы не можете купить с баланса. У Вас мало денег."
        end
      end

      def wex(data)
        if callback_query?
          sset('telebot_method', data)
          trade_overview
        elsif data == 'Отменить'
          cancel_trade
        else
          if !hb_client.has_pending_trade?(@tsx_bot)
            reply_message "#{icon(@tsx_bot.icon_warning)} Заказ был отменен. Начните сначала."
            start
          else
            # 538976685
            reply_message "#{icon(@tsx_bot.icon_wait)} Проверяем WEX код."
            handle('wex')
            uah_price = _buy.discount_price
            seller_bot = Bot[_buy.bot]
            uah_payment = seller_bot.check_wex(data)
            puts "PRICE IN CENTS: #{uah_price}"
            puts "FOUND IN COUPON: #{uah_payment}"
            uah_rate = @tsx_bot.get_var('USD_UAH').to_f
            wex_rate = @tsx_bot.get_var('WEX_UAH').to_f
            needed_extra_wex = uah_price / wex_rate
            needed_uah = needed_extra_wex * uah_rate
            puts "NEEEDED UAH: #{needed_uah}"
            if uah_payment == 'false'
              update_message "#{icon(@tsx_bot.icon_warning)} Неверный WEX код. Помощь /payments"
              handle('trade_overview')
            elsif needed_uah >= uah_price
              update_message "#{icon(@tsx_bot.icon_warning)} Суммы не хватает, зачислено на баланс. Помощь /payments"
              hb_client.cashin(uah_payment, Client::__wex, Meth::__wex, Client::__tsx)
              handle('trade_overview')
            else
              update_message "#{icon(@tsx_bot.icon_success)} Оплата успешно зачислена."
              hb_client.cashin(uah_payment, Client::__wex, Meth::__wex, Client::__tsx)
              finalize_trade(data, Meth::__wex)
            end
          end
        end
      end

      def cancel
        reply_message "#{icon('no_entry_sign')} Отменено успешно."
        serp
      end

      def abuse(data = nil)
        if !data
          handle('abuse')
          reply_message "#{icon('oncoming_police_car')} *Написать жалобу*\nНапишите жалобу в свободной форме. *Обязательно!* укажите, *на какой конкретно бот* жалоба и коротко суть.", btn_cancel
        else
          Bot::chief.say(Client[29407].tele, "Новая жалоба: #{@payload.text}")
          reply_message "#{icon(@tsx_bot.icon_success)} Мы получили Вашу жалобу и обязательно примем меры. Спасибо за отзыв!"
          serp
        end
      end

      def qiwi(data)
        if callback_query?
          sset('telebot_method', data)
          trade_overview
        elsif data == 'Отменить'
          cancel_trade
        else
          if !hb_client.has_pending_trade?(@tsx_bot)
            reply_message "#{icon(@tsx_bot.icon_warning)} Заказ был отменен. Начните сначала."
            start
          else
            # 538976685
            reply_message "#{icon(@tsx_bot.icon_wait)} Проверяем Qiwi платеж по номеру платежа."
            handle('qiwi')
            uah_price = @tsx_bot.cnts(Price[_buy.prc].price)
            used_code = Invoice.where("code like '%#{data.split('-').first}%'").first
            if !used_code.nil?
              hb_client.allow_try
              botrec("Введен использованный код", used_code.code)
              update_message "#{icon(@tsx_bot.icon_warning)} Код уже был использован. Если Вы уверены, что не использовали этот код, создайте запрос в службу поддержки."
              puts "USED CODE". colorize(:red)
              handle('trade_overview')
            else
              seller_bot = Bot[_buy.bot]
              uah_payment = seller_bot.check_qiwi(data)
              # blue "CHECK RESULT: #{uah_payment}"
              # uah_payment = 100
              if uah_payment == 'false'
                update_message "#{icon(@tsx_bot.icon_warning)} Неверный номер платежа в Qiwi. Код пополнения это номер транзакции Qiwi. Помощь /payments"
                handle('trade_overview')
              elsif (uah_payment.to_f+2) < uah_price
                code = Invoice.create(code: data, client: hb_client.id)
                update_message "#{icon(@tsx_bot.icon_warning)} Суммы не хватает, разница зачислена на баланс. Помощь /payments"
                hb_client.cashin(@tsx_bot.cnts(uah_payment), Client::__qiwi, Meth::__qiwi, Client::__tsx)
                handle('trade_overview')
              else
                code = Invoice.create(code: data, client: hb_client.id)
                update_message "#{icon(@tsx_bot.icon_success)} Оплата успешно зачислена."
                hb_client.cashin(@tsx_bot.cnts(uah_payment), Client::__qiwi, Meth::__qiwi, Client::__tsx)
                # Tsc.where(code: data).update(status: Tsc::TSC_CLEARED, client: hb_client.id)
                finalize_trade(data, Meth::__qiwi)
              end
            end
          end
        end
      end

    end
  end
end