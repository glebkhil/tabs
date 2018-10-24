require_relative './requires'
logger = CronLogger.new

hook = 'https://9669c1a3.ngrok.io/hook/'
puts "Bot: " + ARGV[0]
puts "Setting webhook ... "
b = Bot.find(tele: ARGV[0])
puts b.inspect
puts "Token: #{b.token}"
url = hook + b.token.to_s
puts "Webhook: #{url}"
from_bot = Telegram::Bot::Api.new(b.token)
puts from_bot.getWebhookInfo.inspect
from_bot.setWebhook(url: url)
