*#{@tsx_bot.title}* #{@tsx_bot.awards if !@tsx_bot.awards.nil?}
`#{Version.current}`

Клиент #{icon('id')} *#{hb_client.id}*
Баланс *#{@tsx_bot.amo(hb_client.available_cash)}*
Покупок *#{hb_client.buy_trades([Trade::FINALIZED, Trade::FINISHED]).count}* на *#{@tsx_bot.amo(hb_client.buy_trades([Trade::FINALIZED, Trade::FINISHED]).sum(:price))}* #{"\nПродаж *#{hb_client.sell_trades([Trade::FINALIZED, Trade::FINISHED]).count}* на *#{@tsx_bot.amo(hb_client.sell_trades([Trade::FINALIZED, Trade::FINISHED]).sum(:price))}*" if @sh}
Рефералов *#{@tsx_bot.amo(hb_client.client_referals)}*
Заработано *#{@tsx_bot.amo(hb_client.ref_cash)}*
#{"Поддержка" if !@tsx_bot.support.nil?} #{@tsx_bot.support_line if !@tsx_bot.support.nil?}
****
[[]]