require 'telegram/bot'
require 'telegram/bot/exceptions'
require 'net/http/persistent'
require 'raven'
require 'colorize'

class TABTimeout < Timeout::Error; end
class BotController < TSX::ApplicationController

  post '/hook/*' do
    begin
      # [200, {}, ['---------------------- COULD NOT PROCESS']]
      mess = ''
      token = params[:splat].first
      @bot = Telegram::Bot::Client.new(token)
      _tsx_bot = Bot.find(token: token)
      if _tsx_bot.master.nil?
        @tsx_bot = _tsx_bot
      else
        @tsx_bot = Bot[_tsx_bot.master]
      end
      @tsx_host = request.host
      if @bot && @tsx_bot
        parse_update(request.body)
        setup_sessa
        if !hb_client
          mess = "Возникла проблема при регистрации вашего никнейма. Обратитесь в поддержку."
        elsif @tsx_bot.inactive?
          mess = "Бот на техобслуживании."
        elsif hb_client.banned?
          mess = "Вы забанены. Удачи."
        else
          show_typing
          call_handler
          log_update
        end
      end
    rescue Telegram::Bot::Exceptions::ResponseError => re
      hb_client.status = Client::CLIENT_BANNED
      hb_client.save
      mess = re.message
      puts mess
      puts re.backtrace.join("\n\t")
    rescue => ex
      puts "====================================="
      puts ex.message
      puts ex.backtrace.join("\n\t")
      puts mess
      puts "====================================="
    end
    [200, {}, ["----------------------- SUCCESS"]]
  end

  def no_command
    reply_simple 'errors/no_command'
  end

  def no_such_view view
    reply_simple 'errors/no_such_view', view_file: view
  end

end