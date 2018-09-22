require_relative './requires'
l = CronLogger.new

l._say "Expire old trades ... "
trades = Trade::expired_trades
l.answer(trades.count, :green)
trades.each do |trade|
  tsx_bot = Bot[trade.bot]
  if tsx_bot.nil?
    trade.delete
  else
    from_bot = Telegram::Bot::Api.new(tsx_bot.token)
    begin
      l._say "Deleting old trade ##{trade.id} ... "
      trade_item = Item[trade.item]
      trade_item.status = Item::ACTIVE
      trade_item.save
      trade.delete
      buyer = Client[trade.buyer]
      from_bot.send_message(
        chat_id: buyer.tele,
        text: "#{icon(tsx_bot.icon_info)} Вы не оплатили заказ. Товар выставлен на продажу.",
        parse_mode: :markdown,
        reply_markup: Telegram::Bot::Types::ReplyKeyboardMarkup.new(
          keyboard: [[icon(tsx_bot.icon, 'Главная')]],
          resize_keyboard: true
        )
      )
      l.answer('ok', :green)
      [200, {}, ['']]
    rescue => ex
      l.answer(ex.message, :red)
      [200, {}, ['']]
    end
  end
end
DB.disconnect
puts "Finished."
