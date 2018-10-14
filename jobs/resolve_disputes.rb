require_relative './requires'
logger = CronLogger.new

logger.noise "Solving disputes ... "
disputes = Abuse.where(:status => [Abuse::APPROVED, Abuse::REJECTED, Abuse::NO_ITEM])
if disputes.nil?
  logger.say "Nothing to send"
  exit
end
disputes.each do |c|
  t = Trade[c.trade]
  b = Bot[t.bot]
  buyer = Client[t.buyer]
  i = Item[t.item]
  from_bot = Telegram::Bot::Api.new(b.token)
  begin
    logger._say "Sending to #{buyer.username} ... "
    if c.status == Abuse::NO_ITEM
      logger._say "geting item ... "
      found = c.approve
      if found.first == false
        logger.answer(found.last, :green)
        break
      else
        logger.answer('new item assigned', :green)
        break
      end
    end
    if c.status == Abuse::APPROVED
      logger._say "approved dispute ... "
      txt = "#{icon(b.icon_success)} Ваш запрос был удовлетворен. *#{i.product_string} #{i.make('qnt', 'вес')}* #{i.city_string}, #{i.district_string} #{i.full} [Фото клада](#{i.photo.chomp("\n")})"
      from_bot.send_message(
          chat_id: buyer.tele,
          text: txt,
          parse_mode: :markdown
      )
      t.status = Trade::FINALIZED
      t.status
      c.status = Abuse::ARCHIVED
      c.save
      logger.answer('success', :green)
    elsif c.status == Abuse::REJECTED
      logger._say "rejected dispute ... "
      txt = "#{icon(b.icon_warning)} Ваш запрос на перезаклад не был удовлетворен. В перезакладе отказано.\n\nПодробней о политике ненаходов можно прочитать здесь /abuse"
      from_bot.send_message(
          chat_id: buyer.tele,
          text: txt,
          parse_mode: :markdown
      )
      t.status = Trade::FINALIZED
      t.status
      c.status = Abuse::ARCHIVED
      c.save
      logger.answer('success', :green)
    end
    sleep(1)
  rescue Telegram::Bot::Exceptions::ResponseError => e
    logger.answer('fail', :red)
  end
end
DB.disconnect
logger.noise "Finished."