*Общая статистика*

Бот 🅱 *#{@tsx_bot.tele + (@tsx_bot.underscored_name == 1 ? "_bot": "bot")}*
Номер бота *#{@tsx_bot.id}*
Репутация #{icon('parking')} #{Rank::reputation(@tsx_bot.beneficiary)}
Клиентов *#{@tsx_bot.bot_clients.count}*
Баланс *#{@tsx_bot.amo(@tsx_bot.beneficiary.available_cash)}*
Комиссии *#{@tsx_bot.commission}%*
К выплате *#{@tsx_bot.amo(@tsx_bot.not_paid)}*
Выплачено *#{@tsx_bot.amo(@tsx_bot.paid_total)}*

Всего *#{kladov(@tsx_bot.all_items)}*
На продаже *#{kladov(@tsx_bot.active_items)}*
Продано *#{kladov(@tsx_bot.sold_items)}*
Зарезервировано *#{kladov(@tsx_bot.reserved_items)}*
Сегодня *#{@tsx_bot.today_bot_sales(Date.today)}* на *#{@tsx_bot.amo(@tsx_bot.today_income(Date.today))}*
#{share_stat if @tsx_bot.has_shares?}
****
[
    [
        'Админ',
        'Команда',
        'BTC-e код',
    ],
    btn_main
]