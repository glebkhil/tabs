class BtcController < ApplicationController

  post '/btc/*' do
    begin
      @bot = Telegram::Bot::Client.new("468412303:AAF-meB8M7ChZV7_JatgtO_wYUR2BMzdEDU")
      @tsx_bot = Bot.find(token: "468412303:AAF-meB8M7ChZV7_JatgtO_wYUR2BMzdEDU")
      @tsx_host = request.host
      if @bot && @tsx_bot
        parse_update(request.body)
        setup_sessa
        sset('bot_type', 'btc')
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
