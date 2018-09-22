module Telebot
  module Search

    def products(list)
      buts = keyboard(list, 3) do |prod|
        p = Product[prod[:product]]
        "#{icon(p[:icon])} #{p.russian}"
      end
      if hb_client.active_items.count > 0
        buts << [btn_add_item, btn_my_account]
      else
        buts << [btn_add_item, btn_my_account]
      end
    end

    def list_all(list)
      buts = keyboard(list, 2) do |item|
        item.long_title
      end
      buts << [btn_add_item, btn_my_account]
    end

    def items_list(list)
      buts = keyboard(list, 2) do |item|
        item.long_title
      end
      buts << ["#{icon('arrow_backward', 'Район')}", "Продукт #{icon('arrow_forward')}"]
      buts << [btn_add_item, btn_my_account]
    end

    def districts(list)
      buts = keyboard(list, 4) do |d|
        "#{d.russian}"
      end
      buts << ["#{icon('arrow_backward', 'Город')}", "Продукт #{icon('arrow_forward')}"]
      buts << [btn_my_account]
    end

    def cities(list)
      buts = keyboard(list, 4) do |item|
        c = City[item[:city]]
        icon('white_small_square', "#{c.russian}")
      end
      buts << [icon('back', 'Продукт'), btn_my_account]
    end

  end
end