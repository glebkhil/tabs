#{client_details(hb_client)}
****
[
    [
      button("Изменить название", 'my_title'),
      button("Изменить описание", 'my_description')
    ],
    [
      button(hb_client.escrow_helper[:button], hb_client.escrow_helper[:action])
    ],
]

