#{icon(@tsx_bot.icon_new_item)} Выберите фасовку/вес клада.
****
buts ||= []
buts = keyboard(@qnts, 2) do |rec|
  rec.to_str
end
buts
