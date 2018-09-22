#{icon('nut_and_bolt')} Заказы, требующие Вашего внимания.
****
buts = keyboard(hb_client.my_trades(Trade::PENDING)) do |rec|
  it = Item[rec[:id]]
  button("#{it.long_title}", rec[:trade].to_s)
end
buts

