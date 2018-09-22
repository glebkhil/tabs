class Tsc < Sequel::Model(:tsc)

  TSC_NOT_PAID = 0
  TSC_PAID = 1
  TSC_CLEARED = 2

  def self.create_tscx_code(amount)
    p1 = Hashids.new(TSCX_CODE_PASS, 4, "ABCDEFGHIJKLMNOPQRSTUVWXYZ").encode(amount)
    p2 = Hashids.new(TSCX_CODE_PASS, 4, "ABCDEFGHIJKLMNOPQRSTUVWXYZ").encode(Time.now.to_i)
    p3 = Hashids.new(TSCX_CODE_PASS, 4, "ABCDEFGHIJKLMNOPQRSTUVWXYZ").encode(TSC_KEY)
    "#{p1}-#{p2}-#{p3}"
  end

  def self.verify_tscx_code(code)
    hh = Hashids.new(TSCX_CODE_PASS, 4, "ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    res = code.split('-')
    begin
      am = hh.decode(res[0]).first
      tt = hh.decode(res[1]).first
      kk = hh.decode(res[2]).first
      puts "DECODED #{am}-#{tt}-#{kk}".colorize(:blue)
      am.to_i
      Time.at(tt.to_i)
      puts "KEY #{kk.to_i}"
      raise if kk.to_i != TSC_KEY
    rescue => e
      puts "EXXCETPIOn"
      puts e.message
      return 'false'
    end
    tscstored = Tsc.find(code: code)
    puts tscstored.inspect.colorize(:yellow)
    if tscstored.nil?
      puts "NO CODE".colorize(:red)
      return 'false'
    else
      if tscstored.status == TSC_CLEARED
        puts "USED".colorize(:red)
        return 'false'
      elsif tscstored.status == TSC_PAID
        puts "OK".colorize(:green)
        return am.to_s
      else
        puts "NOT PAID".colorize(:red)
        return 'false'
      end
    end
  end

end