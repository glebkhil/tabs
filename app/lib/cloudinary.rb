require 'cloudinary'
require 'fileutils'

module TSX
  module Uploads

    def self.upload(file_url)
      image_url = Dinary::upload(file_url)
      puts image_url
      Uploadsim::upload(image_url)
      Imgur::upload(image_url)
    end

    module Imgur

      def self.upload(file_url)
        puts Faraday.post(
            'https://api.imgur.com/3/image',
            {"authorization": 'Client-ID {{tabinc}}', "content-type": 'multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW'},
            {"image": file_url}).body
      end
    end

    module Uploadsim

      def self.upload(file_url)
        puts "Uploading to Uploads.im... "
        uploaded = Faraday.get("http://uploads.im/api?upload=#{file_url}").body
        puts uploaded[''
             ]
      end

    end

    module Dinary

      def self.upload(file_url)

        puts "Uploading to Cloudinary..."
        Cloudinary.config do |config|
          config.cloud_name = 'hbcelgzxs'
          config.api_key = '826957544189286'
          config.api_secret = 'r1QfJJlPhtrzyIeSay9FoDuomig'
          config.cdn_subdomain = true
        end

        cloudfile = Cloudinary::Uploader.upload(file_url, use_filename: true, unique_filename: true)
        cloudfile['url'].chomp('(').chomp(')')

      end

    end

  end
end