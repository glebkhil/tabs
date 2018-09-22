module TSX
  module Controllers
    module Account

      def my_overview
        reply_simple 'account/my_overview'
      end

      def my_settings
        reply_update 'account/my_settings' do
          reply_inline 'account/my_settings'
        end
      end

      def my_trades
        handle('do_trade')
        reply_inline 'account/my_trades'
      end

      def do_trade(data)
        handle('my_rank_it')
        t = Trade[data]
        b = Item[t.item]
        if t.finalized?
          sset('temp_trade', t)
          reply_update 'search/finalized', item: b, trade: t
        else
          strade(t)
          sbuy(b)
          trade_overview
        end
      end

      def my_rank_it(data)
        hb_client.rank_client(sget('temp_trade'), data)
        # reply_message "Спасибо, что поставили оценку."
        sdel('telebot_search_trading')
        sdel('temp_trade')
        sdel('telebot_search_buying')
        handle('do_trade')
        reply_update 'account/my_trades'
      end

      def item_buttons
        city_cnt = hb_client.my_cities.count
        city = "Города, (#{city_cnt})"
        region_cnt = hb_client.my_districts.count
        region = "Районы, (#{region_cnt})"
        active_cnt = hb_client.all_items.count
        active = "Все клады, (#{active_cnt})"
        product_cnt = hb_client.my_products.count
        product = "Продукт, (#{product_cnt})"
        if active_cnt == 0
          search_buttons = nil
        else
          search_buttons ||=  [
                      button(city_cnt > 1 ? region : city, 'my_cities'),
                      button(product, 'my_products'),
                      button(active, 'my_active')
                  ]
        end
        [search_buttons]
      end

      def my_all_items
        handle('do_single_item')
        reply_simple 'account/item_catalog', what: "list_all", list: hb_client.my_all_items
      end

      def do_my_products
        handle('do_my_cities')
        reply_simple 'account/item_catalog', what: "products", list: hb_client.my_products
      end

      def do_my_cities(product = nil)
        if !product.nil?
          p = Product.find(russian: product)
          sproduct(p)
        else
          p = _product
        end
        handle('do_my_districts')
        reply_simple 'account/item_catalog', what: "cities", list: hb_client.my_cities_by_product(p)
      end

      def do_my_districts(city = nil)
        if !city.nil?
          c = City.find(russian: city)
          scity(c)
        else
          c = _city
        end
        handle('do_my_items')
        reply_simple 'account/item_catalog', what: "districts", list: hb_client.my_districts_by_city(c)
      end

      def do_my_items(district = nil)
        if !district.nil?
          d = District.find(russian: district)
          sdistrict(d)
        else
          d = _district
        end
        handle('do_single_item')
        reply_simple 'account/item_catalog', what: "items_list", list: hb_client.my_items_by_product_district(_product, d)
      end

      def do_single_item(item)
        item_overview(item)
      end

      def my_cancel
        my_overview
      end

      def my_profile
        answer_callback 'Ваша анкета уже открыта'
      end

      def my_escrow_off
        Client.where(id: hb_client.id).update(escrow: 0)
        answer_callback 'Страховка сделок выключена.'
        my_settings
      end

      def my_escrow_on
        Client.where(id: hb_client.id).update(escrow: 30)
        answer_callback 'Страховка сделок включена.'
        my_settings
      end

      def my_description
        handle('do_my_description')
        reply_simple 'account/my_description'
      end

      def do_my_description(data)
        Client.where(id: hb_client.id).update(description: sget('telebot_text_variable'))
        reply_simple 'account/my_overview', txt: 'Описание сохранено.', one_time: false
        unhandle
        my_settings
      end

      def my_title
        handle('do_my_title')
        reply_simple 'account/my_title'
      end

      def do_my_title(data)
        Client.where(id: hb_client.id).update(title: sget('telebot_text_variable'))
        reply_simple 'account/my_overview', txt: 'Название сохранено', one_time: false
        unhandle
        my_settings
      end
    end
  end
end