#{item_data}
****
cities = City.where(country: _country.id)
cits = []
row = 0
cities.each_slice(4) do |slice|
  cits[row] = []
  slice.each do |city|
    cits[row].push button("#{city.russian}", city.id.to_s)
  end
  row =+ 1
end
cits
