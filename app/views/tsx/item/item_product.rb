#{item_data}
****
buts = []
row = 0
Product.all.each_slice(5) do |slice|
  buts[row] = []
  slice.each do |prod|
    buts[row].push button("#{prod.russian}", prod.id.to_s)
  end
  row =+ 1
end
buts

