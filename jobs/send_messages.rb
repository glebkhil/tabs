require_relative './requires'
logger = CronLogger.new

logger.noise "Scheduled messages sending ... "
mess = Spam.find(status: Spam::NEW)
if mess.nil?
  logger.say "Nothing to send"
  exit
end
mess.status = Spam::SENT
mess.log = logger.lines
mess.sent = Time.now
mess.save
tsx_bot = Bot[mess.bot]
from_bot = Telegram::Bot::Api.new(tsx_bot.token)
logger.noise "Message from @#{tsx_bot.tele}"
logger.noise "Recipients: #{I18n::t("spam.kinds.#{mess.kind}")}"
case mess.kind
  when Spam::BOT_ADMINS
    clients = Client.
        join(:team, :client__id => :team__client).
        where(:team__role => Client::HB_ROLE_ADMIN).exclude(role: Client::HB_ROLE_ARCHIVED)
  when Spam::BOT_ALL
    clients = Client.where(:role => Client::HB_ROLE_BUYER)
  when Spam::BOT_CLIENTS
    clients = Client.where(bot: mess.bot).exclude(role: Client::HB_ROLE_ARCHIVED)
  when Spam::BOT_OPERATORS
    clients = Client.
        join(:team, :client__id => :team__client).
        where(:team__bot => mess.bot, :team__role => Client::HB_ROLE_OPERATOR).exclude(role: Client::HB_ROLE_ARCHIVED)
end
logger.noise "Recipient count: #{clients.count}"
clients.each do |c|
  begin
    from_b = Bot[c.bot]
    logger._say "Sending to #{from_b.tele} / #{c.username} ... "
    from_bot = Telegram::Bot::Api.new(from_b.token)
    from_bot.send_message(
        chat_id: c.tele,
        text: mess.text,
        parse_mode: :markdown
    )
    logger.answer('success', :green)
    [200, {}, ['MESSAGE SENT']]
  rescue Telegram::Bot::Exceptions::ResponseError => e
    logger.answer('user blocked bot', :red)
    # c.role = Client::HB_ROLE_ARCHIVED
    c.save
    [200, {}, ['FAILED TO SEND']]
  end
end

DB.disconnect
logger.noise "Finished."