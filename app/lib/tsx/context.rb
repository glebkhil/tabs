require 'yaml/store'
require 'yaml'
module TSX
  module Context

    def search_bots(bot)
      by_bot = []
      if bot.is_chief?
        Bot.where(status: Bot::ACTIVE).each do |b|
          by_bot << b.id
        end
      else
        by_bot << bot.id
      end
      by_bot
    end

    def setup_sessa
      @hb_sessa = Sess.find_or_create(sid: "#{chat}:#{@tsx_bot.tele}", bot: @tsx_bot.id)
    end

    def setup_chat_sessa
      @hb_group = Group.find(status: Group::ACTIVE, title: group_title)
      if !@hb_group.nil?
        @hb_group.tele = chat.to_s
        @hb_group.save
      end
    end

    def set_client_session(client, key, value)
      sessa = Sess.find(sid: "#{client.tele}:#{@tsx_bot.tele}", bot: @tsx_bot.id)
      dat = YAML.load(sessa.data).to_hash
      dat[key.to_sym] = value
      sessa.data = YAML.dump(dat)
      sessa.save
    end

    def clear_sessa
      # sdel('tsx_filter_district')
      # sset('tsx_filter', sget('tsx_city'))
      # unhandle
    end

    def session_hash
      if !@hb_sessa.nil?
        dat = YAML.load(@hb_sessa.data)
      end
      if !dat
        Hash.new
      else
        dat.to_hash
      end
    end

    def sset(key, val)
      all = session_hash
      all[key.to_sym] = val
      @hb_sessa.data = YAML.dump(all)
      @hb_sessa.save
    end

    def sget(key)
      all = session_hash
      all[key.to_sym].nil? ? false : all[key.to_sym]
    end

    def sdel(key)
      all = session_hash
      all.delete(key.to_sym)
      @hb_sessa.data = YAML.dump(all)
      @hb_sessa.save
    end

    def handle(handler)
      puts handler.colorize(:red)
      sset('tsx_handler', handler)
    end

    def unhandle
      sdel('tsx_handler')
    end

    def filter(mod)
      sset('tsx_filter', mod)
    end

    def unfilter
      sdel('tsx_filter')
    end

    def handler?
      sget('tsx_handler')
    end

    def sbuy(item)
      sset('tsx_buying', item)
    end

    def _buy
      sget('tsx_buying')
    end

    def strade(trade)
      sset('tsx_trading', trade)
    end

    def _trade
      sget('tsx_trading')
    end

    def _country
      Country[hb_client.get_var('country')]
    end

    def editable!
      if callback_query?
        sset('tsx_editable', @payload.message.message_id)
      else
        sset('tsx_editable', @payload.message_id)
      end
    end

    def set_editable(id)
      sset('tsx_editable', id)
    end

    def forget_editable
      sdel('tsx_editable')
    end

    def has_editable?
      sget('tsx_editable')
    end

  end
end