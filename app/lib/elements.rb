module TSX

  module Elements

    def button(text, action, pay = nil)
      {text: text, callback_data: action, pay: pay}
    end

    def button_value(text, action)
      Hash.new({text: text, value: action})
    end

    def default_buttons
      [
          [
            hb_client ? button(t('actions.start.my_shop'), 'my_account') : button(t('actions.become_seller'), 'become_seller'),
            button(t('actions.start.main'), 'start')
        ]
      ]
    end

    def home_button
      [
          button(t('actions.start.main'), 'start')
      ]
    end

    def back_button(action)
      [
          button('<< Назад', action)
      ]
    end


    def list_countries(list)
      geos = []
      row = 0
      list.each_slice(3) do |slice|
        geos[row] = []
        slice.each do |country|
          co = ISO3166::Country[country[:code]]
          if !co.nil?
            label = co.emoji_flag << " " << ISO3166::Country[country[:code]].local_name
            geos[row].push button(label, country.id.to_s)
          end
        end
        row =+ 1
      end
      geos
    end

    def list_products(list)
      prods = []
      row = 0
      list.each_slice(3) do |slice|
        prods[row] = []
        slice.each do |product|
          label = t("products.#{product.title}")
          prods[row].push button(label, product.id.to_s)
        end
        row = row + 1
      end
      prods
    end

    def seller_short_info(seller)
      line = ''
      line << "#{seller.hb_title}
#{seller.human_kind}

"
    end

    def account_buttons
      [
        ['Клады', 'Нужен свой бот?'],
        ['Сделки', 'Рефералы', 'Обмен/Вывод']
      ]
    end

    def product_buttons
      buts
    end

  end

end