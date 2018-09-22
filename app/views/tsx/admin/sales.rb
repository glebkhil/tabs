#{icon('euro')} *Продажи системы*

#{darkside_sales}

Итого продаж за месяц *#{@tsx_bot.uah(Darkside::System::turnover.count(:id))}*
Итого за месяц *#{@tsx_bot.uah(Darkside::System::turnover.sum(:amount))}*
****
[[]]