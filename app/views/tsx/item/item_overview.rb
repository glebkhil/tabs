#{item_data}
****
[
  [
    button('Коротко', 'item_details'),
    button('Описание', 'item_full'),
  ],
  [
    button('Вес', 'item_qnt'),
    button('Цена', 'item_price'),
    button('Фотки', 'item_photo'),
  ],
  [
    button('Продукт', 'item_product'),
    button('Город', 'item_city'),
    button('Район', 'item_district')
  ],
  [
    button("#{icon('dart', '')} Активировать", 'item_activate'),
    button("#{icon('scissors', '')} Сделать дубликат", "#{_item.id.to_s}"),
  ]
]
