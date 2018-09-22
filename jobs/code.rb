require_relative 'requires'
code = '00:5036308-28054'
payment_time = code[0..4]
rest_of_code = code[5..-1]
terminal = code[5..9]

puts "code: #{code}"
puts "time: #{payment_time}"
puts "terminal: #{terminal}"
puts "rest of code: #{rest_of_code}"

c_original = Time.parse(payment_time).strftime("%H:%M") + terminal
с_plus = (Time.parse(payment_time) - 1.minute).strftime("%H:%M") + terminal
с_minus = (Time.parse(payment_time) + 1.minute).strftime("%H:%M") + terminal

puts "code_original: #{c_original}"
puts "code_plus: #{с_plus}"
puts "code minus: #{с_minus}"