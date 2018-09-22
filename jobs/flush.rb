require_relative './requires'

url = 'https://tab-flush.herokuapp.com/flush'
puts "Getting all webhooks ... "
Bot.all.each do |b|
  begin
    puts "Token: #{b.tele}"
    from_bot = Telegram::Bot::Api.new(b.token)
    from_bot.deleteWebhook
    upds = from_bot.getUpdates(offset: -1000)
    puts "... got #{upds.inspect} updates"
    sleep(2)
    ur = "#{url}/#{b.token}"
    webhook = from_bot.setWebhook(url: ur)
    puts webhook.getWebhookInfo.inspect
    puts "done"
  rescue => ex
    b.status = Bot::INACTIVE
    b.save
    puts ex.message
  end
end

