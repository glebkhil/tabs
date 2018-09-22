require_relative './requires'
require 'btce'
require 'telegram/bot'

begin
  l = CronLogger.new
  LOGGER = TSX::Logman::Logger.new
  DB.logger = LOGGER

  l.say "Paying out ... ".colorize(:green)
  bots = Bot.where(status: Bot::ACTIVE).order(Sequel.desc(:id)).all
  _tsx_bot = Bot.chief
  _tsx_btce = Btce::TradeAPI.new({key: _tsx_bot.btce_key, secret: _tsx_bot.btce_secret})
  bots.each do |bot|
    if bot.tele == 'TABSHOP'
      amount = bot.not_paid || 0
      if amount <= 0
        l.noise "Nothing to payout"
      else
        l.noise "Paying out for bot #{bot.title}"
        l.noise "Amount to pay: USD #{amount.to_f/100}"
        l._say "Trying to withdraw from BTC-e #{bot.btce_key} .. "
        api = Btce::TradeAPI.new({key: bot.btce_key, secret: bot.btce_secret})
        coupon_resp = api.trade_api_call('CreateCoupon', currency: 'USD', amount: (amount.to_f/100).round(2), receiver: bot.btce_receiver).to_hash
        if coupon_resp['success'] == 0
          l.answer coupon_resp['error'], :green
          from_bot = Telegram::Bot::Client.new(_tsx_bot.token)
          _tsx_bot.notify_admins(from_bot, "#{icon(bot.icon_info)} Бот #{bot.tele} не смог расчитаться. Сообщение от BTC-e: #{coupon_resp['error']}")
        else
          l.answer "Coupon created", :green
          l._say "Trying to deposit to TSX chief .. "
          coupon = coupon_resp['return']['coupon']
          redeem = _tsx_btce.trade_api_call('RedeemCoupon', coupon: coupon).to_hash
          cents = (redeem['return']['couponAmount']).to_f * 100
          l.answer "USD#{cents.to_f/100} redeemed to TSX chief", :green
          bot.clear
        end
        exit
        l.noise "\n\n"
      end
    else
      l.noise "Not SHOPTEST24"
    end
  end

  DB.disconnect
  l.say "Finished.".colorize(:green)

rescue => e
  l.say e.message
end
