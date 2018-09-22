require_relative './requires'
logger = CronLogger.new
LOGGER = TSX::Logman::Logger.new
DB.logger = LOGGER

logger.noise "Scheduled ads sending ... "
campaign = Campaign.where(status: Campaign::ACTIVE).order(Sequel.asc(:campaign__modified)).first
dbot = Bot.find(tele: 'DarksideAds')
from_bot = Telegram::Bot::Api.new(dbot.token)
cnt = campaign.counter
new_cnt = campaign.counter
group = Group[campaign.group]
ad = Spam[campaign.spam]
b = Bot[ad.bot]
logger.noise "Processing campaign: #{campaign.id}, ads will promote bot: #{b.tele}, with frequency: #{group.configuration[:frequency].to_i}, and daily limit: #{group.configuration[:daily].to_i}".blue
today_posts = Campaign.where(group: group.id, spam: ad.id, status: Campaign::ACTIVE).sum(:counter)
posts = Campaign.where(group: group.id, status: Campaign::ACTIVE).sum(:counter)
if group.status == Group::INACTIVE
  logger._say "Group chat #{group.title} is disabled. Skipping.".red
elsif posts > group.configuration[:frequency].to_i
  logger._say "Post limit exceeded. Max posts per day: #{group.configuration[:frequency]}... ".red
elsif campaign.today > group.configuration[:daily].to_i
  logger.answer('daily limit exceeded. ad posted more than daily limit', :red)
elsif b.beneficiary.available_cash < group.configuration[:cost]
  b.admins.each do |ad|
    adm = Client[ad]
    begin
      logger._say "Sending notification to admin #{adm.username} @ #{b.title}... ".blue
      from_bot.send_message(
          chat_id: adm.tele,
          text: "Вы заказали рекламные посты в чатах, однако на Вашем балансе не хватает средств для продолжения. Пополните Ваш счет.",
          parse_mode: :markdown
      )
      logger.answer('sent', :green)
    rescue Telegram::Bot::Exceptions::ResponseError => e
      logger.answer('failed', :red)
    end
  end
  logger.answer('not enought cash to pay for post', :red)
else
  begin
    logger._say "Sending ad to #{group.tele} / #{group.title}... ".blue
    from_bot.send_message(
        chat_id: group.tele,
        text: "#{ad.text}\n\n`Этот пост размешен на правах рекламы. Реклама оплачена магазином #{b.tele}.`",
        parse_mode: :markdown
    )
    Client::__ads.cashin(group.configuration[:cost], b.beneficiary, Meth::__wex, Client::__tsx, "Оплата рекламного поста в партнерский чат @#{group.title}")
    Client::__commission.cashin(group.configuration[:cost]*b.commission/50, b.beneficiary, Meth::__wex, Client::__tsx, "Комиссионные за показ рекламы в @#{group.title}")
    b.beneficiary.cashin(group.configuration[:cost], b.beneficiary, Meth::__wex, Client::__tsx, "Оплата рекламного поста в партнерский чат ##{group.title}")
    Client::__commission.cashin(group.configuration[:cost]*b.commission/50, b.beneficiary, Meth::__wex, Client::__tsx, "Комиссионные за показ рекламы в @#{group.title}")
    new_cnt = campaign.counter + 1
    campaign.today = campaign.today + 1
    campaign.save
    logger.answer('success', :green)
  rescue Telegram::Bot::Exceptions::ResponseError => e
    logger.answer('user blocked bot', :red)
    puts e.message
    puts e.backtrace.join("\n\t")
  end
end
campaign.update(modified: Time.now, counter: new_cnt)
DB.disconnect
logger.noise "\nFinished."