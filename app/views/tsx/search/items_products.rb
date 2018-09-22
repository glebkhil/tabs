#{icon(@product[:icon])} *#{@product.russian}*.
#{City[@district.city].russian}, #{@district.russian}.
Найдено *#{kladov(@item_count)}*.
Действует акция `-#{@tsx_bot.discount}%` на клады старше *#{dney(@tsx_bot.discount_period)}*. Акционные клады помечены значком #{icon(@tsx_bot.icon_old)}.
****
cur = @tsx_bot.get_var('currency')
lab = "грн."
buts = keyboard(@items, 3) do |item|
  "#{item.price_string("UAH", 'грн.')} #{item.id}"
end
buts << [btn_back, btn_main, btn_add_item]-[nil]
