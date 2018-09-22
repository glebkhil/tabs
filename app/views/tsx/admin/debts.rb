#{icon('euro')} *Долги ботов*

Выберите бот и обнулите долг. Обратите внимание, что обнулять долг следует только после фактической его оплаты.
****
buts = keyboard(@list, 3) do |rec|
  bot = Bot[rec[:id]]
  button("#{bot.tele} #{bot.amo(bot.not_paid)}", "#{bot.id}")
end
buts