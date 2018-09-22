#{bread_crumbs}
****
buts = keyboard(@list, 2) do |rec|
  if rec.instance_of?(Product)
    "#{icon(rec[:icon])} #{rec.russian}"
  else
    rec.to_str(@tsx_bot)
  end
end
buts ||= []
buts << @buttons


