class AdsController < ApplicationController

  post '/ads/*' do
    begin
      @bot = Telegram::Bot::Client.new("492518040:AAFot83UPW39OOshuVSkmY44ZHxG285cvF8")
      @tsx_bot = Bot.find(token: "492518040:AAFot83UPW39OOshuVSkmY44ZHxG285cvF8")
      @tsx_host = request.host
      parse_update(request.body)
      setup_sessa
      setup_chat_sessa
      sset('bot_type', 'ads')
      hb_client
      call_chat_handler
      log_update
    rescue => ex
      lg ex.message
      lg ex.backtrace.join("\n\t")
    end
    [200, {}, ['']]
  end

  def no_command
    [200, {}, ['']]
    # reply_simple 'errors/no_command'
  end

  def no_such_view view
    [200, {}, ['']]
    # reply_simple 'errors/no_such_view', view_file: view
  end

end
