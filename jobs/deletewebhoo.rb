require 'telegram/bot'
require 'telegram/bot/types'

puts "Setting webhook ... "
puts "Token: #{ARGV[0]}"
puts "Webhook: #{ARGV[1]}"
from_bot = Telegram::Bot::Api.new(ARGV[0])
puts from_bot.deleteWebhook