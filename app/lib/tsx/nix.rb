module NIX
  class << self
    def check_nix_code(code, pass, acc, keeper)

      web = Mechanize.new
      web.keep_alive = false
      web.agent.open_timeout = 1
      web.agent.set_proxy('54.173.229.200', 80, 'fixie', 'YXawVc9oW2b8ivw')
      batch = code.first
      am = code.last
      nix = web.post("https://www.nixmoney.com/history",
      {
          :PASSPHRASE => pass,
          :ACCOUNTID => acc,
          :STARTMONTH => Date.today.month,
          :STARTDAY => Date.today.day,
          :STARTYEAR => Date.today.year,
          :ENDMONTH => Date.today.month,
          :ENDDAY => Date.today.day,
          :ENDYEAR => Date.today.year,
          :PAYMENTSRECEIVED => 'true',
          :COUNTERFILTER => keeper
        }
      )
      nix.body.split(/[\r\n]+/).each do |trans|
        puts "---"
        transaction = trans.split(',')
        amount = transaction[4]
        # b = transaction.first
        memo = transaction.last
        if amount.to_f == am.to_f
          if memo.include?(batch.to_s)
            puts "MEMO FOUND"
            return amount.to_f * UAH_RATE
          end
        end
      end
      return 'false'
    end
  end
end