class InfoController < ApplicationController

  post '/info/*' do
    begin
      @bot = Telegram::Bot::Client.new("526448873:AAH94fBXS5FMCFPjJK5IxZKa1O9NDJroKRI")
      @tsx_bot = Bot.find(token: "526448873:AAH94fBXS5FMCFPjJK5IxZKa1O9NDJroKRI")
      @tsx_host = request.host
      if @bot && @tsx_bot
        parse_update(request.body)
        setup_sessa
        sset('bot_type', 'info')
        hb_client
        call_handler
        log_update
        [200, {}, ['']]
      else
        [200, {}, ['']]
      end
    rescue => ex
      lg ex.message
      lg ex.backtrace.join("\n\t")
      # reply_simple 'errors/internal'
      [200, {}, ['']]
    end
  end

  def no_command
    reply_simple 'errors/no_command'
  end

  def no_such_view view
    reply_simple 'errors/no_such_view', view_file: view
  end

end
