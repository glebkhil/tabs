class NotEnoughAmount < Exception
end

hash = {:result=>"error", :exception=>"NotEnoughAmount", :param=>333}.to_json
hh = JSON.parse(hash)
if hh[:result] == 'error'
  puts "error"
  ex = eval("NotEnoughAmount.new(#{hash[:param]})")
  raise ex
end