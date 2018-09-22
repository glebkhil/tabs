#{item_data}
****
buts = []
row = 0
@list.each_slice(4) do |slice|
  buts[row] = []
  slice.each do |dist|
    buts[row].push button("#{dist.russian}", dist.id.to_s)
  end
  row =+ 1
end
buts
