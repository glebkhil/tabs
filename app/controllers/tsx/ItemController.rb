module TSX
  module Controllers
    module Public

      def add_item
        not_permitted if !hb_client.is_admin?(@tsx_bot) and !hb_client.is_kladman?(@tsx_bot)
        handle('save_item')
        reply_simple "meine/item_photo"
      end

      def save_item(data = nil)
        fil = @bot.api.get_file(file_id: file?)
        blue fil.inspect
        klad_url = "https://api.telegram.org/file/bot#{@tsx_bot.token}/#{fil['result']['file_path']}"
        puts klad_url
        cloudfile = Cloudinary::Uploader.upload(klad_url, use_filename: true, unique_filename: true)
        puts url = cloudfile['url']
        sset('tsx_new_item', url)
        reply_simple "meine/item_desc"
        handle('save_desc')
      end

      def save_desc(data)
        sset('tsx_new_item_desc', @payload.text)
        prod = sget('tsx_filter_product')
        qns = Price.where(bot: @tsx_bot.id, product: prod.id)
        reply_simple "meine/choose_qnt", qnts: qns
        handle('save_completely')
      end

      def save_location
        sset('tsx_new_item_long', @payload.location.longitude)
        sset('tsx_new_item_lat', @payload.location.latitude)
        reply_simple 'meine/item_desc'
        handle('save_completely')
      end

      def save_completely(data = nil)
        d = sget('tsx_filter')
        p = sget('tsx_filter_product')
        pric = Price.find(qnt: @payload.text.split(' ').first, product: sget('tsx_filter_product').id, bot: @tsx_bot.id)
        puts "PRICE: #{pric.inspect}"
        desc = sget('tsx_new_item_desc')
        # gps = " https://www.google.com.ua/maps/@#{sget('tsx_new_item_lat').to_s},#{sget('tsx_new_item_long').to_s}?hl=ru"
        gps = ""
        city = City[d.city]
        it = Item.create(
            product: p.id,
            photo: "#{sget('tsx_new_item')} #{desc}",
            qnt: nil,
            price: nil,
            prc: pric.id,
            city: city.id,
            district: d.id,
            client: hb_client.id,
            bot: @tsx_bot.id,
            status: Item::ACTIVE
        )
        reply_message "#{icon(@tsx_bot.icon_success)} Клад #{it.id} добавлен."
        sdel('tsx_new_item')
        sdel('tsx_new_item_long')
        sdel('tsx_new_item_lat')
        unhandle
        start
      end

    end
  end
end