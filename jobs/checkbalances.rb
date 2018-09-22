require_relative './requires'
l = CronLogger.new

l.say "Checking all balances ... ".colorize(:green)
bots = Bot.where(status: Bot::ACTIVE).order(Sequel.desc(:id)).all
bots.each do |bot|

  l.noise "Processing bot #{bot.title}"

  l._say "BTC-e USD .. "
  if !bot.btce_key.nil?
    bal = bot.check_btce_balance
    l.answer(bal.to_s, :light_green)
  else
    l.answer('n/a', :light_red)
  end

  l._say "Easypay .. "
  if !bot.easypay_login.nil?
    eas = bot.check_easy_balance
    l.answer(eas.to_s, :on_green)
  else
    l.answer('n/a', :light_red)
  end

  l.noise "\n\n"

end

DB.disconnect
l.say "Finished.".colorize(:green)


