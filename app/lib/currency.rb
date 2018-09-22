require 'action_view/helpers/number_helper'

module TSX
  module Currency

    def getrate(cur)
      bot_currency = self.get_var('currency')
      rate = self.get_var("USD_#{bot_currency}")
      rate.to_s
    end

    def cnts(am)
      bot_currency = self.get_var('currency')
      rate = self.get_var("USD_#{bot_currency}")
      cents = ((am.to_f / rate.to_f)*100).round
      cents
    end

    def amo(am)
      bot_currency = self.get_var('currency')
      bot_currency_label = self.get_var('currency_label')
      "#{(((am.to_f * self.get_var("USD_#{bot_currency}").to_i)/100).round)}#{bot_currency_label}"
    end

    def amo_currency(am, currency, label = '')
      "#{(((am.to_f * self.get_var("USD_#{currency}").to_i)/100).round)}#{label}"
    end

    def uah(cents)
      "#{((cents.to_f / 100) * self.get_var('USD_UAH').to_f).round}грн."
    end

    def btc(cents)
      bestchange_rates = BestchangeRates.new
      uah_btc = bestchange_rates.rates "Visa/MasterCard USD" => "Bitcoin (BTC)"
      btc_rate = cents.to_f / 100 / uah_btc.first[:give]
      "#{btc_rate.round(5)} BTC"
    end

    def uah_by_rate(cents, pair = 'WEX_UAH')
      "#{((cents.to_f / 100) * self.get_var(pair).to_i).round(2)}грн."
    end

    def usd(cents)
      "$#{(cents.to_f / 100).round(2)}"
    end

    def amo_pure(am)
      bot_currency = self.get_var('currency')
      "#{(((am.to_f * self.get_var("USD_#{bot_currency}").to_i)/100).round)}"
    end

    def amo_color(am, cur)
      # self.amo(am, cur)
      # money = Money.new(am, "USD")
      # sum = money.exchange_to(cur).to_s.to_f.round
      # puts "ORIGINAL AMOUNT: #{money}"
      # puts "CONVERTED TO RUB: #{sum}"
      # return am.to_i < 0 ? "<span class='red'>-#{self.amo(am.abs, cur)}</span>" : self.amo(am, hb_currency)
    end

    def in_btc(am)
      # am * self.get_var('USD_UAH').to_f
      # money = Money.new(am, "UAH")
      # money.exchange_to("USD")
      '0.001'
    end

  end
end
