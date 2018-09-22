require_relative './requires'
logger = CronLogger.new

images = Item.where("photo like '%res.%' and status = 1")
puts "images: #{images.count}"