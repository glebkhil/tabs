require_relative './requires'
logger = CronLogger.new

logger.noise "Verifying bots ... \n"
var = Bot.where(status: Bot::ACTIVE)
var.each do |b|
  weekday = Date.today.wday

  if [4, 5].include?(weekday)
    debt = b.not_paid
    # puts "debt: #{debt}"
    logger._say "Verifying debt for #{b.tele} ... "
    logger.answer("#{b.amo(debt)}", :green)
    if debt > 0
      from_bot = Telegram::Bot::Api.new(b.token)
      admins = Team.where(bot: b.id, role: Client::HB_ROLE_ADMIN)
      admins.each do |a|
        admin = Client[a.client]
        logger._say("  - #{admin.username} .. ")
        begin
          from_bot.send_message(
              chat_id: admin.tele,
              text: "⚠ Ваша задолженность составляет *#{b.amo(b.not_paid)}* Погасите ее, чтобы продолжить использовать бот. Бот будет деактивирован *в субботу*, если задолженность не будет погашена. WEX код можно купить на одном из обменников с http://bestchange.ru.",
              parse_mode: :markdown
          )
          logger.answer("notified", :green)
        rescue Telegram::Bot::Exceptions::ResponseError => e
          # puts e.message
          logger.answer("Telegram exception", :red)
        end
      end
    end
  end

  if weekday == 6
    logger._say "Verifying debt for #{b.tele} ... "
    if b.not_paid > 1800
      logger.answer('got debt. bot deactivated', :red)
      b.status = Bot::INACTIVE
      b.save
      from_bot = Telegram::Bot::Api.new(b.token)
      admins = Team.where(bot: b.id, role: Client::HB_ROLE_ADMIN)
      admins.each do |a|
        admin = Client[a.client]
        logger._say("  - #{admin.username} .. ")
        begin
          from_bot.send_message(
              chat_id: admin.tele,
              text: "⚠ Ваш бот деактивирован. Оплатите задолженность в полном объеме, чтобы продолжить продажи.",
              parse_mode: :markdown
          )
          logger.answer("notified", :green)
        rescue Telegram::Bot::Exceptions::ResponseError => e
          puts e.message
          logger.answer("Telegram exception", :red)
        end
      end
    else
      logger.answer('no debt', :blue)
    end
  end
  logger._say "\n"
end

DB.disconnect
logger.noise "Finished."