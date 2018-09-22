require_relative './requires'

logger = CronLogger.new
logger.noise "Setting webhook ... "
logger.noise "Token: #{ARGV[0]}"
logger.noise "Webhook: #{ARGV[1]}"

img = Magick::ImageList.new("../bin/photo_2017-07-17_09-35-04.jpg")
txt = Magick::Draw.new

img.annotate(txt, 800, 600, 0, 0, "my super long text that needs to be auto line breaked and cropped") {
  txt.gravity = Magick::NorthGravity
  txt.pointsize = 22
  txt.fill = "#ffffff"
  txt.font_family = 'helvetica'
  txt.font_weight = Magick::BoldWeight
}

img.format = "jpeg"

return img.to_blob