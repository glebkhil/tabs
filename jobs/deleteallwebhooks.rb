require_relative './requires'

puts "Setting webhooks to #{ARGV[0]} ... "
Bot.all.each do |b|
  begin
    puts "Token: #{b.token}"
    from_bot = Telegram::Bot::Api.new(b.token)
    #puts from_bot.getWebhookInfo.inspect
    ur = "#{ARGV[0]}/#{b.token}"
    puts ur.inspect
    from_bot.deleteWebhook
    puts "done"
  rescue => ex
    puts ex.message
  end
end

