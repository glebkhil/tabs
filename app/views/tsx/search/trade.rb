*#{_buy.product_string} #{(topay = Price[_buy.prc]).qnt}*
#{"\nМагазин" if @ch} *#{@seller_bot.title if @ch}* #{"\nРепутация" if @ch} #{reputation(@ben)+"\n" if @ch}
#{method_helper(@method, _buy)}
Номер клада *##{_buy.id}*
Ваш баланс *#{@tsx_bot.amo(hb_client.available_cash)}*
Город *#{_buy.city_string}, #{_buy.district_string}*
#{"Поддержка" if !@seller_bot.support.nil?} #{"[@#{@seller_bot.support}](t.me/#{@seller_bot.support})" if !@seller_bot.support.nil?}
О платежах /payments
#{method_desc(@method)}
****
buts ||= []
@avlbl = @seller_bot.available_payments
buts = keyboard(@avlbl, 2) do |rec|
    m = Meth[rec.meth]
    button(icon(@method == m.title ? 'large_blue_circle' : 'white_circle', m.russian), m.title)
end
buts